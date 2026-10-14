//
//  ImageGenerationError.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// What can go wrong making a picture.
public enum ImageGenerationError: Error, LocalizedError, Sendable, Equatable {

    /// The folder is not a Core AI diffusion export (no readable `metadata.json`).
    case notABundle(String)

    /// The export is a diffusion model, but not one of ``GenerationModel``.
    case unsupportedModel(String)

    /// Core AI could not load the export.
    case loadFailed(String)

    /// The prompt was empty or too long.
    case invalidPrompt(String)

    /// Fewer than one picture, or more than ``ImageGenerator/maximumCount``.
    case invalidCount(Int)

    /// A step count outside ``GenerationModel/stepRange``.
    case invalidSteps(Int, GenerationModel)

    /// A masked edit could not be planned or put back — no mask, or masks
    /// that do not fit the picture.
    case invalidMask(String)

    /// More reference pictures than FLUX.2 takes (the edited picture counts).
    case tooManyReferences(Int)

    /// Editing needs FLUX.2 Klein with its editing parts installed.
    case editingUnavailable(String)

    /// The model ran and failed.
    case generationFailed(String)

    /// The task was cancelled before the picture was done.
    case cancelled

    /// The picture could not be written.
    case writeFailed(String)

    /// A recipe that could not be read, or a field it does not have.
    case invalidRecipe(String)

    /// A person file or LoRA that could not be read, or does not fit the slot.
    case invalidPerson(String)

    /// A person asked for where the export or the run cannot take one.
    case personUnavailable(String)

    /// A value for a slot the style does not have, or an empty one.
    case invalidStyleValue(String)

    public var errorDescription: String? {
        switch self {
        case .notABundle(let path): "\(path) is not a Core AI image-generation export"
        case .unsupportedModel(let name):
            "\(name) is not a model this runs (\(GenerationModel.allCases.map(\.displayName).joined(separator: ", ")))"
        case .loadFailed(let why): "the model could not be loaded: \(why)"
        case .invalidPrompt(let why): why
        case .invalidCount(let count): "\(count) is not a picture count this makes (1–\(ImageGenerator.maximumCount))"
        case .invalidSteps(let steps, let model):
            "\(steps) is not a step count \(model.displayName) runs (\(model.stepRange.lowerBound)–\(model.stepRange.upperBound))"
        case .invalidMask(let why): why
        case .tooManyReferences(let count):
            "\(count) pictures in is more than FLUX.2 takes (\(ImageGenerator.maximumReferences), counting the edited one)"
        case .editingUnavailable(let why): why
        case .generationFailed(let why): "the model failed: \(why)"
        case .cancelled: "cancelled"
        case .writeFailed(let why): "the picture could not be written: \(why)"
        case .invalidRecipe(let why): why
        case .invalidPerson(let why): why
        case .personUnavailable(let why): why
        case .invalidStyleValue(let why): why
        }
    }
}
