//
//  ImageAspect.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// The shapes a picture can come in.
///
/// Each shape is its own export: Core AI traces a transformer at one size, and
/// one asset holding several shapes does not help — it compiles EVERY function
/// when it loads and caches a full compiled copy of each (measured: sixteen
/// FLUX shapes compiled to 116 GB). So FLUX.2 Klein 4B keeps a small folder per
/// shape (its autoencoder and `metadata.json`) and a transformer per shape and
/// mode — text to image, editing — each fetched the first time it is used. Not
/// every shape has both: see ``GenerationModel/aspects`` and
/// ``GenerationModel/editAspects``. SANA Sprint keeps the first four shapes,
/// Klein 9B the square only.
public enum ImageAspect: String, Sendable, Codable, CaseIterable {

    /// 1024 × 1024.
    case square = "1:1"

    /// 1344 × 768 — 16:9 within 1.6 %, and a multiple of 32 so both models
    /// take it (FLUX needs 16, SANA's autoencoder 32).
    case landscape = "16:9"

    /// 768 × 1344 — the 16:9 export turned upright, for Shorts, Reels and
    /// stories.
    case vertical = "9:16"

    /// 896 × 1120 — exactly 4:5, for feed posts; also a multiple of 32.
    case portrait = "4:5"

    /// 1152 × 864 — exactly 4:3, the shape of a phone's photos. FLUX only.
    case classic = "4:3"

    /// 864 × 1152 — 4:3 upright. FLUX editing only.
    case classicTall = "3:4"

    /// 1248 × 832 — exactly 3:2, the shape of a camera's photos. FLUX only.
    case photo = "3:2"

    /// 832 × 1248 — 3:2 upright. FLUX editing only.
    case photoTall = "2:3"
}
