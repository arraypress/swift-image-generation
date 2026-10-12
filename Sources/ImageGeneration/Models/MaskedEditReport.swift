//
//  MaskedEditReport.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// What a masked edit changed, measured on the result.
public struct MaskedEditReport: Sendable, Equatable {

    /// The share of the picture the edit was allowed to touch (grown and
    /// feathered masks), 0…1.
    public let regionFraction: Double

    /// The largest difference, 0–255, between the result and the original
    /// anywhere outside that region. 0 means every other pixel is the
    /// original's, byte for byte.
    public let untouchedMaxDifference: Int

    public init(regionFraction: Double, untouchedMaxDifference: Int) {
        self.regionFraction = regionFraction
        self.untouchedMaxDifference = untouchedMaxDifference
    }
}
