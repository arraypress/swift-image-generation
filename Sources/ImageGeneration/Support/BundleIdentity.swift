//
//  BundleIdentity.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Which model an export folder holds, from the `metadata.json` Apple's
/// exporter writes beside the `.aimodel` files.
enum BundleIdentity {

    static func model(at folder: URL) throws(ImageGenerationError) -> GenerationModel {
        let file = folder.appendingPathComponent("metadata.json")
        guard let data = try? Data(contentsOf: file),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              root["kind"] as? String == "diffusion" else {
            throw .notABundle(folder.path)
        }
        let source = (root["source"] as? [String: Any])?["hf_model_id"] as? String
        let name = root["name"] as? String ?? source ?? "unknown"
        return try model(named: name, source: source, compression: root["compression"] as? String)
    }

    /// The model whose checkpoint is `source` (or ends in `name`) and, where two
    /// share a checkpoint, whose ``GenerationModel/compression`` is `compression`.
    static func model(named name: String, source: String?, compression: String? = nil) throws(ImageGenerationError) -> GenerationModel {
        for model in GenerationModel.allCases where source == model.sourceModel
            || model.sourceModel.hasSuffix("/" + name) {
            if let expected = model.compression, expected != compression { continue }
            return model
        }
        throw .unsupportedModel(name)
    }
}
