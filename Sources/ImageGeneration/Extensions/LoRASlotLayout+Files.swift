//
//  LoRASlotLayout+Files.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CryptoKit
import Foundation

public extension LoRASlotLayout {

    /// The file name an export keeps its layout under.
    static let fileName = "slot.json"

    /// Reads an export's `slot.json`.
    init(contentsOf url: URL) throws(ImageGenerationError) {
        do {
            self = try JSONDecoder().decode(LoRASlotLayout.self, from: Data(contentsOf: url))
        } catch {
            throw .invalidPerson("\(url.path) is not a LoRA slot layout: \(error.localizedDescription)")
        }
    }

    /// The layout beside an export's transformer, or `nil` for a plain export.
    static func inBundle(_ bundle: URL) throws(ImageGenerationError) -> LoRASlotLayout? {
        let url = bundle.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try LoRASlotLayout(contentsOf: url)
    }

    /// What a person records to say which slot it fits: a digest of the layers'
    /// names and shapes. The rank is left out, as a smaller LoRA is padded.
    var identifier: String {
        let text = layers.map { "\($0.name):\($0.inFeatures):\($0.outFeatures)" }.joined(separator: "\n")
        return SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
