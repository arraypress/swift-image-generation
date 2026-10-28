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
/// FLUX.3 Klein (2026-10-28) is the model for text: in bfloat16 it spelled
/// printed signs and chalk handwriting right where the others garble them; at
/// 4 bits it is quicker but garbles handwriting.
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

    /// Black Forest Labs' FLUX.3 [klein] in bfloat16 — the model for text:
    /// signs, menus and handwriting spelled right, square only, no editing,
    /// 17 GB. FLUX Kommunity License: non-commercial, output filtered or
    /// reviewed before it is shared (``isNonCommercial``).
    case flux3Klein = "flux3-klein"

    /// FLUX.3 [klein] with its weights at 4 bits, for quick drafts: about half
    /// the time of the full model for one picture and 5.4 GB, but it garbles
    /// handwriting the full model writes right.
    case flux3KleinSmall = "flux3-klein-small"
}
