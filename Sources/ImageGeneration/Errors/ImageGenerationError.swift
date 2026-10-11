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

    /// Editing needs FLUX.2 Klein with its editing parts installed.
    case editingUnavailable(String)

    /// The model ran and failed.
    case generationFailed(String)

    /// The task was cancelled before the picture was done.
    case cancelled

    /// The picture could not be written.
    case writeFailed(String)

    public var errorDescription: String? {
        switch self {
        case .notABundle(let path): "\(path) is not a Core AI image-generation export"
        case .unsupportedModel(let name): "\(name) is not a model this runs (FLUX.2 Klein 4B or SANA Sprint 1.6B)"
        case .loadFailed(let why): "the model could not be loaded: \(why)"
        case .invalidPrompt(let why): why
        case .invalidCount(let count): "\(count) is not a picture count this makes (1–\(ImageGenerator.maximumCount))"
        case .editingUnavailable(let why): why
        case .generationFailed(let why): "the model failed: \(why)"
        case .cancelled: "cancelled"
        case .writeFailed(let why): "the picture could not be written: \(why)"
        }
    }
}
