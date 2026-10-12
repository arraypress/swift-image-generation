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
        }
    }

    /// The Hugging Face checkpoint the Core AI export was made from.
    var sourceModel: String {
        switch self {
        case .flux2Klein4B: "black-forest-labs/FLUX.2-klein-4B"
        case .sanaSprint16B: "Efficient-Large-Model/Sana_Sprint_1.6B_1024px_diffusers"
        case .flux2Klein9B: "black-forest-labs/FLUX.2-klein-9B"
        }
    }

    /// Whether the model's licence forbids commercial use (FLUX.2 Klein 9B:
    /// FLUX Non-Commercial License v2.1, which also requires output to be
    /// filtered or reviewed before it is shared). A caller should show those
    /// terms and have them accepted before first use.
    var isNonCommercial: Bool { self == .flux2Klein9B }

    /// Whether the model can edit an existing picture (image-to-image).
    var supportsEditing: Bool { self == .flux2Klein4B }

    /// The shapes this library's exports come in: 9B is square only.
    var aspects: [ImageAspect] { self == .flux2Klein9B ? [.square] : ImageAspect.allCases }

    /// Whether to load the model's parts one at a time (`lowMemory`) on a Mac
    /// with this much memory. Measured for 9B on 36 GB: one at a time took a
    /// median ≈110 s at 4.1 GB peak, all at once 176 s under memory pressure.
    func loadsPartsOneAtATime(physicalMemory: UInt64) -> Bool {
        self == .flux2Klein9B && physicalMemory < 48 * 1_073_741_824
    }
}
