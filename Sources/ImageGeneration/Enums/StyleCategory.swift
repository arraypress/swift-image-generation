//
//  StyleCategory.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Where a style is listed.
public enum StyleCategory: String, Codable, Sendable, CaseIterable {
    case headshots
    case dating
    case lifestyle
    case fashion
    case travel
    case retro
    case seasonal
    case events
    case couples
    case fantasy
    case art
    case food
}
