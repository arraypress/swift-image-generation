//
//  Person.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Someone (or something) a LoRA has learned, ready for a LoRA-slot export.
///
/// The matrices are the LoRA's own, at its own rank, with its alpha/rank scale
/// already folded into `B`, stored as half floats: 37 MB at rank 16 for FLUX.2
/// Klein 4B. They are padded to the slot's rank only when a run uses them.
public struct Person: Sendable, Equatable {

    /// One layer's pair of matrices.
    public struct Layer: Sendable, Equatable {
        /// The layer's module path; one of the slot layout's.
        public let name: String
        /// Down-projection, `[rank, in]`, little-endian half floats.
        public let a: Data
        /// Up-projection, `[out, rank]`, little-endian half floats, scale folded in.
        public let b: Data

        public init(name: String, a: Data, b: Data) {
            self.name = name
            self.a = a
            self.b = b
        }
    }

    /// The name runs ask for it by: `--person owl`.
    public let name: String

    /// The words that call it up in a prompt, e.g. `zxq plush owl`.
    public let trigger: String

    /// The LoRA's rank.
    public let rank: Int

    /// The model it was trained on, e.g. `black-forest-labs/FLUX.2-klein-base-4B`.
    public let baseModel: String

    /// ``LoRASlotLayout/identifier`` of the layout it fits.
    public let layout: String

    /// The trained layers. Slot layers it leaves out run as the plain model.
    public let layers: [Layer]

    public init(name: String, trigger: String, rank: Int, baseModel: String, layout: String, layers: [Layer]) {
        self.name = name
        self.trigger = trigger
        self.rank = rank
        self.baseModel = baseModel
        self.layout = layout
        self.layers = layers
    }
}
