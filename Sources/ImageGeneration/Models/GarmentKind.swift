//
//  GarmentKind.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// What a garment is, as far as dressing someone in it goes: which part of
/// a person it replaces, and what it is called in an instruction.
public enum GarmentKind: String, Codable, Sendable, CaseIterable {
    /// A t-shirt, shirt, blouse, sweater, hoodie — worn on the upper body.
    case top
    /// A jacket, blazer or coat.
    case outerwear
    /// A dress: upper body and legs.
    case dress
    case skirt
    case trousers
    case shorts
    case shoes
    case hat
}

/// Where on a person a garment goes: words for SAM 3, tried as
/// ``RegionMask/candidates(for:)`` tries them, the best that passes kept.
public struct GarmentRegion: Sendable, Equatable {

    /// The words to try, in order.
    public let words: [String]

    /// Whether the step fails without it. An optional region is used when
    /// the person has it (a blazer to take off as well as the t-shirt).
    public let required: Bool

    public init(words: [String], required: Bool) {
        self.words = words
        self.required = required
    }
}
