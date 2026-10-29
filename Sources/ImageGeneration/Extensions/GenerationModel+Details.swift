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
        case .flux2Klein9B: "FLUX.2 [klein] 9B"
        case .flux3Klein: "FLUX.3 [klein]"
        case .flux3KleinSmall: "FLUX.3 [klein] 4-bit"
        }
    }

    /// The Hugging Face checkpoint the Core AI export was made from.
    var sourceModel: String {
        switch self {
        case .flux2Klein4B: "black-forest-labs/FLUX.2-klein-4B"
        case .sanaSprint16B: "Efficient-Large-Model/Sana_Sprint_1.6B_1024px_diffusers"
        case .flux2Klein9B: "black-forest-labs/FLUX.2-klein-9B"
        case .flux3Klein, .flux3KleinSmall: "black-forest-labs/flux-3-image-klein"
        }
    }

    /// The `compression` an export's `metadata.json` records for this model, where
    /// two models share a checkpoint; `nil` takes any.
    var compression: String? {
        switch self {
        case .flux3Klein: "none"
        case .flux3KleinSmall: "4bit"
        default: nil
        }
    }

    /// Whether the model is FLUX.3 [klein], at either size.
    var isFlux3: Bool { self == .flux3Klein || self == .flux3KleinSmall }

    /// Whether the model draws text unless told not to: FLUX.2 Klein 9B and
    /// FLUX.3 Klein, the models chosen for their text. The others are told not
    /// to, since they misspell.
    var drawsTextByDefault: Bool { self == .flux2Klein9B || isFlux3 }

    /// Whether the model's licence restricts commercial use (FLUX.2 Klein 9B:
    /// FLUX Non-Commercial License v2.1; FLUX.3 Klein: FLUX Kommunity License
    /// v1.0, whose output only a Qualifying User may use commercially). Both
    /// require output to be filtered or reviewed before it is shared. A caller
    /// should show those terms and have them accepted before first use.
    var isNonCommercial: Bool { self == .flux2Klein9B || isFlux3 }

    /// Whether the model can edit an existing picture (image-to-image):
    /// FLUX.2 Klein 4B, and FLUX.3 Klein at either size.
    var supportsEditing: Bool { self == .flux2Klein4B || isFlux3 }

    /// The longest prompt accepted, in characters. FLUX.3's text window holds
    /// 1,040 tokens — an edit record with its box table runs past the others'
    /// 2,000 characters — and its pipeline refuses, never cuts, a prompt past
    /// the window.
    var maximumPromptLength: Int { isFlux3 ? 6000 : 2000 }

    /// The step counts the model accepts. SANA Sprint is a 1–4-step model
    /// (its export defaults to 2, with a tuned midpoint); FLUX.2 Klein is
    /// step-distilled for 4 — fewer is rougher, more helps little — and runs
    /// up to 28, where an undistilled FLUX would stop. FLUX.3 Klein is a flow
    /// map trained for 1–16 (4 measured as good as 16).
    var stepRange: ClosedRange<Int> {
        switch self {
        case .sanaSprint16B: 1...4
        case .flux3Klein, .flux3KleinSmall: 1...16
        default: 1...28
        }
    }

    /// The shapes this library's exports draw from text in: FLUX.2 Klein 4B and
    /// FLUX.3 Klein (both sizes) six (no upright 3:4 or 2:3), SANA four, 9B the
    /// square only.
    var aspects: [ImageAspect] {
        switch self {
        case .flux2Klein4B, .flux3Klein, .flux3KleinSmall: [.square, .landscape, .vertical, .portrait, .classic, .photo]
        case .sanaSprint16B: [.square, .landscape, .vertical, .portrait]
        case .flux2Klein9B: [.square]
        }
    }

    /// The shapes this library's exports edit in: FLUX.2 Klein 4B and FLUX.3
    /// seven — the shapes photos come in (no 4:5) — and the others none.
    var editAspects: [ImageAspect] {
        supportsEditing ? [.square, .landscape, .vertical, .classic, .classicTall, .photo, .photoTall] : []
    }

    /// Whether to load the model's parts one at a time (`lowMemory`, the lite
    /// tier) on a Mac with this much memory. Measured for 9B on 36 GB: one at a
    /// time took a median ≈110 s at 4.1 GB peak, all at once 176 s under memory
    /// pressure. For 4B and SANA one at a time draws the same pixels in the same
    /// time, and holds 14.6 GB resident at most instead of 20.3 GB (4B; SANA
    /// 10.8 instead of 12.0), so every Mac under 24 GB loads them that way.
    func loadsPartsOneAtATime(physicalMemory: UInt64) -> Bool {
        physicalMemory < Self.fullTierMemory(for: self)
    }

    /// The memory below which ``loadsPartsOneAtATime(physicalMemory:)`` says yes:
    /// 48 GB for 9B, 24 GB for the others.
    static func fullTierMemory(for model: GenerationModel) -> UInt64 {
        (model == .flux2Klein9B ? 48 : 24) * 1_073_741_824
    }
}
