//
//  MaskedEditPlan.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics

/// The square a masked edit works on: around everything the masks cover,
/// with room to spare, in the picture's pixels from the top-left. It may run
/// past a picture's short side; the part outside is filled from the nearest
/// edge before editing and never written back.
public struct MaskedEditPlan: Sendable, Equatable {

    /// The square's left edge (may be negative).
    public let x: Int
    /// The square's top edge (may be negative).
    public let y: Int
    /// The square's side.
    public let side: Int
    /// The picture's size.
    public let imageWidth: Int
    public let imageHeight: Int

    public init(x: Int, y: Int, side: Int, imageWidth: Int, imageHeight: Int) {
        self.x = x
        self.y = y
        self.side = side
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
    }

    /// The square as a rectangle, top-left origin.
    public var rect: CGRect { CGRect(x: x, y: y, width: side, height: side) }
}
