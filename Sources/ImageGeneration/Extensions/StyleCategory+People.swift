//
//  StyleCategory+People.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

public extension StyleCategory {

    /// Whether the category's scenes are of people — and so have faces a
    /// face fix may need to redraw. Food is dishes and interiors are rooms;
    /// every other category puts a person in the frame.
    var featuresPeople: Bool { self != .food && self != .interiors }
}
