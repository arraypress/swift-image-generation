//
//  LoRASlotLayout.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The layers a LoRA-slot transformer takes matrices for, in input order — what
/// the export's `slot.json` holds.
///
/// A slot export computes `W·x + B·(A·x)` in each of these layers, with `A`
/// (`[rank, in]`) and `B` (`[out, rank]`) arriving as inputs; all-zero matrices
/// leave it the plain model.
public struct LoRASlotLayout: Codable, Sendable, Equatable {

    /// One wrapped layer.
    public struct Layer: Codable, Sendable, Equatable {
        /// The layer's module path, e.g. `transformer_blocks.0.attn.to_q`.
        public let name: String
        /// Its input width.
        public let inFeatures: Int
        /// Its output width.
        public let outFeatures: Int

        public init(name: String, inFeatures: Int, outFeatures: Int) {
            self.name = name
            self.inFeatures = inFeatures
            self.outFeatures = outFeatures
        }

        enum CodingKeys: String, CodingKey {
            case name
            case inFeatures = "in"
            case outFeatures = "out"
        }
    }

    /// The largest LoRA rank the slot takes; smaller ones are zero-padded.
    public let rank: Int

    /// The wrapped layers, in the order their inputs are numbered.
    public let layers: [Layer]

    public init(rank: Int, layers: [Layer]) {
        self.rank = rank
        self.layers = layers
    }
}
