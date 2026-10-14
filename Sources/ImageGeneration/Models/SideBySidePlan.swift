//
//  SideBySidePlan.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics

/// How a side-by-side edit lays out its one picture: the part of the
/// photo around the masks on the left, the thing to bring in on the right.
public struct SideBySidePlan: Sendable, Equatable {

    /// The part of the photo shown on the left, in its pixels from the
    /// top-left; it may run past the photo's edges (filled from the nearest
    /// edge). Its shape is the left panel's.
    public let panel: CGRect
    /// The left panel's width in the model's picture; the right panel is the rest.
    public let panelWidth: Int
    /// The model's picture: `canvas × canvas`.
    public let canvas: Int
    /// The square the result is put back through, as a masked edit's.
    public let square: MaskedEditPlan
}
