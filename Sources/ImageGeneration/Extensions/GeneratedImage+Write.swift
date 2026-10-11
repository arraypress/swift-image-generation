//
//  GeneratedImage+Write.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension GeneratedImage {

    /// Writes the picture as PNG, JPEG or HEIC (from the extension), marked
    /// as AI-generated: IPTC digital-source type `trainedAlgorithmicMedia`,
    /// the model in AISystemUsed and `generator` as the creator tool.
    ///
    /// - Parameters:
    ///   - url: Where to write; `.png`, `.jpg`/`.jpeg` or `.heic`.
    ///   - generator: The tool, e.g. "imagine 0.1.0".
    ///   - embedPrompt: Also write the prompt (IPTC AIPromptInformation). Off
    ///     by default — a prompt can be private.
    func write(to url: URL, generator: String, embedPrompt: Bool = false) throws(ImageGenerationError) {
        try ProvenanceWriter.write(image, to: url, model: model, generator: generator,
                                   prompt: embedPrompt ? prompt : nil)
    }

    /// The IPTC digital-source type a written file carries, or `nil`.
    static func digitalSourceType(of url: URL) -> String? { ProvenanceWriter.digitalSourceType(of: url) }
}
