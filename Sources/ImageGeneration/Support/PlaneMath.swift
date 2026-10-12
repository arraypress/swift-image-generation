//
//  PlaneMath.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Single-channel float planes for masked edits: grow (a max filter), blur
//  (three box passes ≈ a Gaussian), and a normalised blur that averages only
//  where a weight allows. Plain Swift over arrays: deterministic, the same on
//  macOS and iOS, and testable without a GPU.
//

/// Float planes, row-major, `width × height`.
enum PlaneMath {

    /// Grows the non-zero area by `radius` pixels (a square max filter).
    static func grow(_ plane: [Float], width: Int, height: Int, radius: Int) -> [Float] {
        guard radius > 0, width > 0, height > 0 else { return plane }
        var rows = [Float](repeating: 0, count: plane.count)
        for y in 0..<height {
            let base = y * width
            for x in 0..<width {
                let lo = max(0, x - radius), hi = min(width - 1, x + radius)
                var best: Float = 0
                for i in lo...hi where plane[base + i] > best { best = plane[base + i] }
                rows[base + x] = best
            }
        }
        var out = [Float](repeating: 0, count: plane.count)
        for x in 0..<width {
            for y in 0..<height {
                let lo = max(0, y - radius), hi = min(height - 1, y + radius)
                var best: Float = 0
                for j in lo...hi where rows[j * width + x] > best { best = rows[j * width + x] }
                out[y * width + x] = best
            }
        }
        return out
    }

    /// A Gaussian-like blur of standard deviation `sigma`: three box passes
    /// each way, edges clamped.
    static func blur(_ plane: [Float], width: Int, height: Int, sigma: Double) -> [Float] {
        guard sigma > 0.3, width > 0, height > 0 else { return plane }
        // Three boxes of width w have variance (w² − 1) / 4.
        let boxWidth = (4 * sigma * sigma + 1).squareRoot()
        let radius = max(1, Int((boxWidth - 1) / 2 + 0.5))
        var a = plane
        for _ in 0..<3 {
            a = boxRows(a, width: width, height: height, radius: radius)
            a = boxColumns(a, width: width, height: height, radius: radius)
        }
        return a
    }

    /// `blur(value × weight) / blur(weight)`: an average that leaves out
    /// whatever the weight excludes (an opaque occluder), so its colour does
    /// not bleed into the average around it. Falls back to the plain blur
    /// where nothing nearby carries weight.
    static func normalisedBlur(_ plane: [Float], weight: [Float], width: Int, height: Int, sigma: Double) -> [Float] {
        var weighted = [Float](repeating: 0, count: plane.count)
        for i in plane.indices { weighted[i] = plane[i] * weight[i] }
        let numerator = blur(weighted, width: width, height: height, sigma: sigma)
        let denominator = blur(weight, width: width, height: height, sigma: sigma)
        let plain = blur(plane, width: width, height: height, sigma: sigma)
        var out = [Float](repeating: 0, count: plane.count)
        for i in plane.indices {
            out[i] = denominator[i] > 1e-3 ? numerator[i] / denominator[i] : plain[i]
        }
        return out
    }

    private static func boxRows(_ plane: [Float], width: Int, height: Int, radius: Int) -> [Float] {
        var out = [Float](repeating: 0, count: plane.count)
        let span = Float(2 * radius + 1)
        for y in 0..<height {
            let base = y * width
            var sum: Float = 0
            for i in -radius...radius { sum += plane[base + min(max(i, 0), width - 1)] }
            for x in 0..<width {
                out[base + x] = sum / span
                sum += plane[base + min(x + radius + 1, width - 1)] - plane[base + max(x - radius, 0)]
            }
        }
        return out
    }

    private static func boxColumns(_ plane: [Float], width: Int, height: Int, radius: Int) -> [Float] {
        var out = [Float](repeating: 0, count: plane.count)
        let span = Float(2 * radius + 1)
        for x in 0..<width {
            var sum: Float = 0
            for j in -radius...radius { sum += plane[min(max(j, 0), height - 1) * width + x] }
            for y in 0..<height {
                out[y * width + x] = sum / span
                sum += plane[min(y + radius + 1, height - 1) * width + x] - plane[max(y - radius, 0) * width + x]
            }
        }
        return out
    }
}
