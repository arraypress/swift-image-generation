//
//  Person+Files.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension Person {

    /// What a training run on FLUX.2 Klein 4B is assumed to have started from
    /// when the LoRA does not say: the undistilled base, the one meant for training.
    static let defaultBaseModel = "black-forest-labs/FLUX.2-klein-base-4B"

    /// The rule a person's name follows, for messages.
    static let nameRule = "letters, digits, - and _, up to 40"

    /// Whether `name` can name a person — and so a folder, safely.
    static func isValidName(_ name: String) -> Bool {
        !name.isEmpty && name.count <= 40 && !name.hasPrefix("-") && !name.hasPrefix(".")
            && name.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-" || $0 == "_") }
    }

    /// Reads a person file.
    init(contentsOf url: URL) throws(ImageGenerationError) {
        let data: Data
        do { data = try Data(contentsOf: url, options: .mappedIfSafe) } catch {
            throw .invalidPerson("could not read \(url.path): \(error.localizedDescription)")
        }
        self = try PersonFile.decode(data)
    }

    /// The trigger recorded in a person file, read from its header alone —
    /// for showing a prompt without loading the matrices.
    static func trigger(contentsOf url: URL) throws(ImageGenerationError) -> String {
        let metadata = try SafeTensors.metadata(of: url)
        guard metadata["format"] == PersonFile.format, let trigger = metadata["trigger"], !trigger.isEmpty else {
            throw .invalidPerson("\(url.path) is not a person file")
        }
        return trigger
    }

    /// Writes this person as a person file.
    func write(to url: URL) throws(ImageGenerationError) {
        do { try PersonFile.encode(self).write(to: url, options: .atomic) } catch {
            throw .writeFailed("\(url.path): \(error.localizedDescription)")
        }
    }

    /// A trainer's LoRA (safetensors, PEFT/diffusers naming) as a person for a slot.
    ///
    /// - Parameters:
    ///   - lora: The LoRA's bytes.
    ///   - name: What runs will call it.
    ///   - trigger: The words that call it up — the trigger it was trained with.
    ///   - layout: The slot it must fit.
    ///   - baseModel: What it was trained on, if the file does not say.
    ///   - alpha: The LoRA's alpha, if the file does not say; its rank otherwise (scale 1).
    /// - Throws: ``ImageGenerationError/invalidPerson(_:)`` naming what does not fit.
    static func importing(lora: Data, name: String, trigger: String, layout: LoRASlotLayout,
                          baseModel: String? = nil, alpha: Double? = nil) throws(ImageGenerationError) -> Person {
        guard isValidName(name) else { throw .invalidPerson("\(name) is not a person's name (\(nameRule))") }
        let words = trigger.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !words.isEmpty else { throw .invalidPerson("a person needs a trigger: the words it was trained with") }
        return try PersonFile.importLoRA(lora, name: name, trigger: words, layout: layout, baseModel: baseModel, alpha: alpha)
    }

    /// The bytes its matrices take.
    var byteCount: Int { layers.reduce(0) { $0 + $1.a.count + $1.b.count } }
}
