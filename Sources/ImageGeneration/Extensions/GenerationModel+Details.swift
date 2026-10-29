//
//  GenerationModel+Details.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

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

    /// The most pictures the model takes in at once, an edited one included:
    /// FLUX.3 ten (diffusers' bound; its editor's reference length is variable),
    /// FLUX.2 Klein four (its traced reference route holds four quarter grids).
    var maximumReferences: Int { isFlux3 ? 10 : 4 }

    /// The most pixels a FLUX.3 picture holds: 3840 × 2160 (8.3 megapixels, or 2880 × 2880
    /// square), the largest measured — 18 minutes on a 36 GB Mac.
    static let flux3MaximumPixels = 3840 * 2160

    /// The longest side a FLUX.3 picture may have: its exports' VAE takes up to 4096.
    static let flux3MaximumSide = 4096

    /// Whether FLUX.3 can draw `width` × `height`: sides in multiples of 16 up to
    /// ``flux3MaximumSide``, at most ``flux3MaximumPixels`` in all.
    static func isFlux3Size(width: Int, height: Int) -> Bool {
        width > 0 && height > 0 && width % 16 == 0 && height % 16 == 0
            && width <= flux3MaximumSide && height <= flux3MaximumSide && width * height <= flux3MaximumPixels
    }

    /// A FLUX.3 size of `width` × `height`'s shape holding about `pixels` pixels,
    /// sides in multiples of 16 — what an edit draws at unless told otherwise. A
    /// shape within 1% of a named one takes its size (a phone's 4:3 photo draws
    /// at 1152 × 864); any other keeps its own. Never past ``flux3MaximumPixels``.
    static func flux3Size(fittingWidth width: Int, height: Int, pixels: Int = 1024 * 1024) -> (width: Int, height: Int) {
        // A photo within 1% of a named shape takes that shape's exact size: a phone's 4:3 is
        // 1152 × 864, as `--aspect 4:3` draws, not 1184 × 880 from rounding each side alone.
        if pixels == 1024 * 1024, let named = ImageAspect.matching(width: width, height: max(1, height), within: 0.01) {
            return named.size
        }
        let target = Double(min(pixels, flux3MaximumPixels))
        let scale = (target / Double(max(1, width * height))).squareRoot()
        let fitted = (width: max(16, Int((Double(width) * scale / 16).rounded()) * 16),
                      height: max(16, Int((Double(height) * scale / 16).rounded()) * 16))
        return isFlux3Size(width: fitted.width, height: fitted.height)
            ? fitted : (max(16, fitted.width - 16), max(16, fitted.height - 16))
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

    /// The named shapes the model draws from text in: FLUX.3 every one (it draws
    /// any size — ``isFlux3Size(width:height:)``), FLUX.2 Klein 4B six (no upright
    /// 3:4 or 2:3), SANA four, 9B the square only.
    var aspects: [ImageAspect] {
        switch self {
        case .flux2Klein4B: [.square, .landscape, .vertical, .portrait, .classic, .photo]
        case .flux3Klein, .flux3KleinSmall: ImageAspect.allCases
        case .sanaSprint16B: [.square, .landscape, .vertical, .portrait]
        case .flux2Klein9B: [.square]
        }
    }

    /// The named shapes the model edits in: FLUX.3 every one (any size, in fact),
    /// FLUX.2 Klein 4B seven — the shapes photos come in (no 4:5) — the others none.
    var editAspects: [ImageAspect] {
        if isFlux3 { return ImageAspect.allCases }
        return supportsEditing ? [.square, .landscape, .vertical, .classic, .classicTall, .photo, .photoTall] : []
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
