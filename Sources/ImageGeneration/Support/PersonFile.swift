//
//  PersonFile.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  A person on disk, and a trainer's LoRA turned into one.
//
//  The person file is itself a safetensors file — `<layer>.lora_A` [rank, in]
//  and `<layer>.lora_B` [out, rank] in F16, scale folded into B — with the
//  name, trigger, rank, base model and slot layout in its metadata, so any
//  safetensors reader can open it.
//
//  Importing accepts the names LoRA trainers write for FLUX.2's transformer:
//  PEFT/diffusers (`transformer.<layer>.lora_A.weight`, or
//  `base_model.model.<layer>…`) and the bare `<layer>.lora_A`. Every layer must
//  be one the slot has, with its exact shape; anything else is refused by name
//  rather than dropped, because a silently skipped layer is a likeness that
//  quietly fails to arrive.
//

import Foundation

enum PersonFile {

    /// What the metadata's `format` key says a person file is.
    static let format = "imagine-person"

    /// The version this writes and reads.
    static let version = "1"

    /// Prefixes trainers put before the layer path.
    static let prefixes = ["transformer.", "base_model.model.", "model.", "diffusion_model."]

    // MARK: - Person files

    static func encode(_ person: Person) -> Data {
        var tensors: [(name: String, dtype: String, shape: [Int], bytes: Data)] = []
        for layer in person.layers {
            let inFeatures = layer.a.count / 2 / max(person.rank, 1)
            let outFeatures = layer.b.count / 2 / max(person.rank, 1)
            tensors.append((layer.name + ".lora_A", "F16", [person.rank, inFeatures], layer.a))
            tensors.append((layer.name + ".lora_B", "F16", [outFeatures, person.rank], layer.b))
        }
        let metadata = ["format": format, "version": version, "name": person.name, "trigger": person.trigger,
                        "rank": String(person.rank), "base_model": person.baseModel, "slot_layout": person.layout]
        return SafeTensors.write(metadata: metadata, tensors: tensors)
    }

    static func decode(_ data: Data) throws(ImageGenerationError) -> Person {
        let (metadata, tensors) = try SafeTensors.read(data)
        guard metadata["format"] == format else {
            throw .invalidPerson("not a person file (no \"format\": \"\(format)\" in its metadata) — "
                                 + "a trainer's LoRA is imported first: imagine people import")
        }
        guard metadata["version"] == version else {
            throw .invalidPerson("a person file of version \(metadata["version"] ?? "?"); this reads version \(version)")
        }
        guard let name = metadata["name"], let trigger = metadata["trigger"], let layout = metadata["slot_layout"],
              let rank = metadata["rank"].flatMap(Int.init), rank > 0 else {
            throw .invalidPerson("a person file without its name, trigger, rank or slot layout")
        }
        var layers: [Person.Layer] = []
        for key in tensors.keys.sorted() where key.hasSuffix(".lora_A") {
            let layer = String(key.dropLast(".lora_A".count))
            guard let a = tensors[key], let b = tensors[layer + ".lora_B"], a.dtype == "F16", b.dtype == "F16" else {
                throw .invalidPerson("\(layer) is missing its B matrix or is not F16")
            }
            layers.append(Person.Layer(name: layer, a: Data(a.bytes), b: Data(b.bytes)))
        }
        return Person(name: name, trigger: trigger, rank: rank, baseModel: metadata["base_model"] ?? "",
                      layout: layout, layers: layers)
    }

    // MARK: - Importing a LoRA

    /// A LoRA's layer path with the trainer's prefix and suffix removed, and
    /// which of the pair it is; `nil` for a key that is not a LoRA matrix.
    static func split(_ key: String) -> (layer: String, isA: Bool)? {
        let suffixes: [(String, Bool)] = [(".lora_A.weight", true), (".lora_B.weight", false),
                                          (".lora_A.default.weight", true), (".lora_B.default.weight", false),
                                          (".lora_A", true), (".lora_B", false)]
        for (suffix, isA) in suffixes where key.hasSuffix(suffix) {
            var layer = String(key.dropLast(suffix.count))
            for prefix in prefixes where layer.hasPrefix(prefix) { layer.removeFirst(prefix.count) }
            return (layer, isA)
        }
        return nil
    }

    static func importLoRA(_ data: Data, name: String, trigger: String, layout: LoRASlotLayout,
                           baseModel: String?, alpha: Double?) throws(ImageGenerationError) -> Person {
        let (metadata, tensors) = try SafeTensors.read(data)
        if tensors.keys.contains(where: { $0.contains("lora_down") || $0.hasPrefix("lora_unet") }) {
            throw .invalidPerson("this is a kohya-style LoRA (lora_down / lora_up); convert it to the diffusers "
                                 + "format first, or train with a PEFT/diffusers trainer")
        }
        var pairs: [String: (a: SafeTensors.Tensor?, b: SafeTensors.Tensor?)] = [:]
        var unknown: [String] = []
        for (key, tensor) in tensors {
            if let (layer, isA) = split(key) {
                var pair = pairs[layer] ?? (nil, nil)
                if isA { pair.a = tensor } else { pair.b = tensor }
                pairs[layer] = pair
            } else if !key.hasSuffix(".alpha") {
                unknown.append(key)
            }
        }
        guard unknown.isEmpty else {
            throw .invalidPerson("\(unknown.count) tensors are not LoRA matrices, e.g. \(unknown.sorted().prefix(3).joined(separator: ", "))")
        }
        guard !pairs.isEmpty else { throw .invalidPerson("no LoRA matrices in this file") }
        // Per-layer alphas (`<layer>.alpha`), which some trainers write instead of one in the metadata.
        var alphas: [String: Double] = [:]
        for (key, tensor) in tensors where key.hasSuffix(".alpha") {
            if let layer = split(String(key.dropLast(".alpha".count)) + ".lora_A")?.layer,
               let value = SafeTensors.floats(tensor).first {
                alphas[layer] = Double(value)
            }
        }
        let slot = Dictionary(uniqueKeysWithValues: layout.layers.map { ($0.name, $0) })
        let foreign = pairs.keys.filter { slot[$0] == nil }.sorted()
        guard foreign.isEmpty else {
            throw .invalidPerson("\(foreign.count) layers are not in this model's LoRA slot, e.g. "
                                 + "\(foreign.prefix(3).joined(separator: ", ")) — was it trained on FLUX.2 Klein 4B?")
        }
        var rank: Int?
        var layers: [Person.Layer] = []
        for target in layout.layers {
            guard let pair = pairs[target.name] else { continue }
            guard let a = pair.a, let b = pair.b else { throw .invalidPerson("\(target.name) has only one of its two matrices") }
            guard a.shape.count == 2, b.shape.count == 2, a.shape[0] == b.shape[1] else {
                throw .invalidPerson("\(target.name)'s matrices do not pair up (\(a.shape) and \(b.shape))")
            }
            let layerRank = a.shape[0]
            guard a.shape[1] == target.inFeatures, b.shape[0] == target.outFeatures else {
                throw .invalidPerson("\(target.name) is \(b.shape[0])×\(a.shape[1]); the slot's is "
                                     + "\(target.outFeatures)×\(target.inFeatures) — a different model")
            }
            if let rank, rank != layerRank { throw .invalidPerson("the layers have different ranks (\(rank) and \(layerRank))") }
            rank = layerRank
            guard layerRank <= layout.rank else {
                throw .invalidPerson("rank \(layerRank) is more than the slot takes (\(layout.rank)); train at rank \(layout.rank) or less")
            }
            let layerAlpha = alphas[target.name]
            let scale = (layerAlpha ?? alpha ?? metadata["alpha"].flatMap(Double.init)
                         ?? metadata["lora_alpha"].flatMap(Double.init) ?? Double(layerRank)) / Double(layerRank)
            let scaledB = SafeTensors.floats(b).map { $0 * Float(scale) }
            guard scaledB.count == b.shape.reduce(1, *) else { throw .invalidPerson("\(target.name)'s B is the wrong size") }
            layers.append(Person.Layer(name: target.name, a: try SafeTensors.halfFloats(a, name: target.name + ".lora_A"),
                                       b: HalfFloat.fromFloats(scaledB)))
        }
        return Person(name: name, trigger: trigger, rank: rank ?? 0,
                      baseModel: baseModel ?? metadata["base_model"] ?? Person.defaultBaseModel,
                      layout: layout.identifier, layers: layers)
    }
}
