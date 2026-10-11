//
//  GenerationModel+Details.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

public extension GenerationModel {

    /// The name people know it by.
    var displayName: String {
        switch self {
        case .flux2Klein4B: "FLUX.2 [klein] 4B"
        case .sanaSprint16B: "SANA Sprint 1.6B"
        }
    }

    /// The Hugging Face checkpoint the Core AI export was made from.
    var sourceModel: String {
        switch self {
        case .flux2Klein4B: "black-forest-labs/FLUX.2-klein-4B"
        case .sanaSprint16B: "Efficient-Large-Model/Sana_Sprint_1.6B_1024px_diffusers"
        }
    }

    /// Whether the model can edit an existing picture (image-to-image).
    var supportsEditing: Bool { self == .flux2Klein4B }

    /// The side of the square images the exports produce, in pixels. Both
    /// were exported at 1024 × 1024 only; other sizes need another export.
    var imageSize: Int { 1024 }
}
