//
//  GenerationModel.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// The models this library runs.
///
/// Chosen by measurement on an M3 Max (2026-10-11) from five candidates:
/// FLUX.2 Klein 4B is the only one that spelled a short sign correctly and it
/// edits existing images; SANA Sprint 1.6B is about ten times faster. FLUX.2
/// Klein 9B (2026-10-12) is the opt-in "quality" model: a tie with 4B on most
/// prompts, clearly better at longer text, about 2.3× slower, non-commercial.
public enum GenerationModel: String, Sendable, Codable, CaseIterable {

    /// Black Forest Labs' FLUX.2 [klein] 4B — quality, text-to-image and editing.
    case flux2Klein4B = "flux2-klein-4b"

    /// NVIDIA's SANA Sprint 1.6B — drafts in about two seconds; no editing.
    case sanaSprint16B = "sana-sprint-1.6b"

    /// Black Forest Labs' FLUX.2 [klein] 9B — better longer text, about two
    /// minutes a picture on a 36 GB Mac, square only, no editing. FLUX
    /// Non-Commercial License: non-commercial use, and output must be filtered
    /// or reviewed before it is shared (``isNonCommercial``).
    case flux2Klein9B = "flux2-klein-9b"
}
