//
//  SeamMatch.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The seam of a masked edit. FLUX hands its square back a shade off the
//  picture it was given — on the grey studio wall of the dressing fixtures,
//  paler and cooler by +5…+10 per channel everywhere, wall and body alike
//  (measured 2026-10-14 on the raw output of the striped-top edit). The
//  ring a mask grows by therefore drew a pale outline round a dressed body,
//  and the wall the model painted where a wider garment had been came out
//  pale as well. So: the shade is measured where the region does not reach
//  (and the two pictures roughly agree), spread smoothly inward, and used
//  twice — a ring pixel outside the masks keeps the original where the
//  edit, shade taken out, only repeats it; and the edit's own pixels that
//  show the surroundings (a painted wall, a continued trouser leg) have the
//  shade taken out. Anything else the edit drew — the garment — is never
//  recoloured.
//

import Foundation

enum SeamMatch {

    /// RGB distance (0–255) at which an outside pixel counts ~60% as a
    /// measure of the shade; a pixel the edit really changed counts ~0.
    static let agree: Float = 24
    /// The shade is spread with a blur of this share of the square's side
    /// (17 px on a 585 px square: it reaches the seam from where the region
    /// ends, ~11 px out).
    static let spread = 0.03
    /// Shade taken out, an edit pixel within `same` of the original (RGB,
    /// after a 1 px blur against grain) is the original; beyond `different`
    /// it is the edit's. Moving these 4/12 … 8/20 changed nothing measurable.
    static let same: Float = 6, different: Float = 16
    /// An edit pixel within `wallNear` of the surroundings' colour (shade
    /// taken out) is the surroundings, and loses the shade; beyond `wallFar`
    /// it is left alone.
    static let wallNear: Float = 10, wallFar: Float = 24
    /// A kept zone stops this many pixels short of anything not kept: an
    /// anti-aliased fringe sits between two colours, and half-kept it drew a
    /// thin white line where an old t-shirt's sleeve had been.
    static let shrink = 2

    /// How much of the original to keep at each pixel of the square (0…1),
    /// and the edit with the shade taken out where it shows the surroundings.
    ///
    /// - Parameters:
    ///   - original: The original's R, G, B planes over the square (0–255).
    ///   - edit: The edit's planes, same layout.
    ///   - thing: What the masked thing looks like near each pixel (the
    ///     original's colour averaged over the masks nearby).
    ///   - region: The composite's weight; 0 where the region does not reach.
    static func match(original: [[Float]], edit: [[Float]], thing: [[Float]], region: [Float], side: Int,
                      plan: MaskedEditPlan) -> (keep: [Float], edit: [[Float]]) {
        let count = side * side
        // Where the shade is measured: outside the region, inside the picture,
        // and where the two pictures roughly agree.
        var reference = [Float](repeating: 0, count: count)
        for i in 0..<count where region[i] == 0 {
            let x = plan.x + i % side, y = plan.y + i / side
            guard x >= 0, x < plan.imageWidth, y >= 0, y < plan.imageHeight else { continue }
            reference[i] = expf(-distanceSquared(original, edit, i) / (2 * agree * agree))
        }
        let sigma = max(4, Double(side) * spread)
        let weight = PlaneMath.blur(reference, width: side, height: side, sigma: sigma)
        var shaded: [[Float]] = [], surroundings: [[Float]] = [], residual: [[Float]] = []
        for c in 0..<3 {
            var offset = [Float](repeating: 0, count: count), colour = offset
            for i in 0..<count {
                offset[i] = (original[c][i] - edit[c][i]) * reference[i]
                colour[i] = original[c][i] * reference[i]
            }
            let shade = PlaneMath.blur(offset, width: side, height: side, sigma: sigma)
            let around = PlaneMath.blur(colour, width: side, height: side, sigma: sigma)
            var e = [Float](repeating: 0, count: count), s = e, r = e
            for i in 0..<count {
                // Too far from any measured pixel: no shade, no surroundings.
                let known = weight[i] > 1e-3
                e[i] = edit[c][i] + (known ? shade[i] / weight[i] : 0)
                s[i] = known ? around[i] / weight[i] : .nan
                r[i] = e[i] - original[c][i]
            }
            shaded.append(e); surroundings.append(s)
            residual.append(PlaneMath.blur(r, width: side, height: side, sigma: 1))
        }
        var keep = [Float](repeating: 0, count: count)
        var out = edit
        for i in 0..<count where !surroundings[0][i].isNaN {
            let r = residual[0][i] * residual[0][i] + residual[1][i] * residual[1][i] + residual[2][i] * residual[2][i]
            let alike = 1 - smoothstep(r.squareRoot(), same, different)
            // The surroundings or the masked thing's fringe (which must still
            // go)? Whichever colour the original is nearer.
            let toSurroundings = distanceSquared(original, surroundings, i).squareRoot()
            let toThing = distanceSquared(original, thing, i).squareRoot()
            let share = toSurroundings / max(toSurroundings + toThing, 1e-3)
            keep[i] = alike * (1 - smoothstep(share, 0.35, 0.65))
            let painted = 1 - smoothstep(distanceSquared(shaded, surroundings, i).squareRoot(), wallNear, wallFar)
            for c in 0..<3 { out[c][i] = edit[c][i] + (shaded[c][i] - edit[c][i]) * painted }
        }
        let notKept = PlaneMath.grow(keep.map { 1 - $0 }, width: side, height: side, radius: shrink)
        for i in 0..<count { keep[i] = 1 - notKept[i] }
        return (PlaneMath.blur(keep, width: side, height: side, sigma: 1), out)
    }

    static func distanceSquared(_ p: [[Float]], _ q: [[Float]], _ i: Int) -> Float {
        let r = p[0][i] - q[0][i], g = p[1][i] - q[1][i], b = p[2][i] - q[2][i]
        return r * r + g * g + b * b
    }

    static func smoothstep(_ v: Float, _ lo: Float, _ hi: Float) -> Float {
        let t = min(1, max(0, (v - lo) / (hi - lo)))
        return t * t * (3 - 2 * t)
    }
}
