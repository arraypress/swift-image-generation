//
//  GeneratedImage.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics

/// One picture a model made, and what made it.
public struct GeneratedImage: Sendable {

    /// The picture, at the export's size (1024 × 1024, or 1344 × 768 for 16:9).
    public let image: CGImage

    /// The seed that made it. The same model, prompt and seed make the same
    /// picture, byte for byte.
    public let seed: UInt32

    /// The model that made it.
    public let model: GenerationModel

    /// The prompt as the caller wrote it.
    public let prompt: String

    /// The prompt the model was given — `prompt` with the no-text suffix
    /// unless text was allowed.
    public let promptSent: String

    /// Whether this edited a picture rather than starting from noise.
    public let edited: Bool

    /// How long the model took, in seconds, not counting loading.
    public let seconds: Double

    public init(image: CGImage, seed: UInt32, model: GenerationModel, prompt: String,
                promptSent: String, edited: Bool, seconds: Double) {
        self.image = image
        self.seed = seed
        self.model = model
        self.prompt = prompt
        self.promptSent = promptSent
        self.edited = edited
        self.seconds = seconds
    }
}
