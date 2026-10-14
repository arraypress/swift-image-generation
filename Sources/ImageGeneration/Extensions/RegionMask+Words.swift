//
//  RegionMask+Words.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics

public extension RegionMask {

    /// The words to ask a segmenter for when looking for `word`: the word
    /// itself first, then the words people use for the same thing — a
    /// t-shirt is also "tshirt", "top", "shirt"; a jacket "blazer", "coat".
    static func candidates(for word: String) -> [String] { RegionWords.candidates(for: word) }

    /// Which candidate to use, given each one's best score in the order
    /// tried: the first whenever it reaches `minimum`, else the best other
    /// that does; `nil` when none does — never one below the floor.
    static func chooseWord(_ scored: [(word: String, score: Double)], minimum: Double) -> String? {
        RegionWords.choose(scored, minimum: minimum)
    }
}

public extension RegionMask {

    /// The box of every pixel at or above 128, top-left origin; `nil` when
    /// the mask is empty.
    var bounds: CGRect? {
        guard let box = ReferenceFrame.bounds(pixels, width: width, height: height) else { return nil }
        return CGRect(x: box.x, y: box.y, width: box.width, height: box.height)
    }
}
