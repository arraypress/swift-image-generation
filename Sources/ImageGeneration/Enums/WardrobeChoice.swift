//
//  WardrobeChoice.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Which cut of a scene's wardrobe to describe.
public enum WardrobeChoice: String, Codable, Sendable, CaseIterable {
    /// Wording that assumes nothing — the default.
    case neutral
    /// The feminine cut where a scene has one, otherwise the neutral wording.
    case feminine
    /// The masculine cut where a scene has one, otherwise the neutral wording.
    case masculine
    /// Say nothing about clothes: for a subject that wears none, a pet or a dish.
    case none
}
