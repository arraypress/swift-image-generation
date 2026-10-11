//
//  ImageAspect.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// The shapes a picture can come in. Each is its own export: Core AI traces a
/// transformer for one shape, and a model compiled for two shapes keeps two
/// full compiled copies (measured: FLUX's two-function transformer compiled
/// to 14 GB). So each non-square shape is a separate, lazily fetched folder
/// beside the square export, sharing its text encoder.
public enum ImageAspect: String, Sendable, Codable, CaseIterable {

    /// 1024 × 1024.
    case square = "1:1"

    /// 1344 × 768 — 16:9 within 1.6 %, and a multiple of 32 so both models
    /// take it (FLUX needs 16, SANA's autoencoder 32).
    case landscape = "16:9"
}
