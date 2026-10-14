//
//  StripeReader.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Whether a garment is striped, from its own picture: the lightness down
//  the garment's middle, row by row, repeats. Horizontal stripes only:
//  read column by column too, a pair of trainers side by side scored 0.22
//  and a print 0.00 — too near the line — and no vertically striped
//  garment was there to measure. The
//  dressing instruction needs to know: a striped top came back with white
//  bands thinner than its own (23% of the garment against 35%) until the
//  instruction said "striped" and "its stripes as many and as wide as shown"
//  (measured 2026-10-14 on generated fashion photos).
//

import Foundation

enum StripeReader {

    /// The repeat (autocorrelation peak) at and above which a garment is
    /// striped. Measured on the six garment pictures of the dressing tests
    /// only: the striped knit top 0.44; two monstera-print dresses −0.11
    /// and −0.14, a corduroy jacket −0.11, trousers −0.17, trainers −1.
    static let striped = 0.25

    /// A lightness swing (OKLab L ×100) below this across the profile is no
    /// pattern at all, however regular: a plain garment's folds.
    static let minimumSwing = 15.0

    /// How regularly the lightness repeats down the garment, −1…1: the first
    /// autocorrelation peak of its row profile after it first goes negative.
    /// `lightness` is OKLab L ×100 per pixel, `.nan` off the garment.
    static func regularity(_ lightness: [Double], width: Int, height: Int) -> Double {
        var minX = width, maxX = -1, minY = height, maxY = -1
        for y in 0..<height {
            for x in 0..<width where !lightness[y * width + x].isNaN {
                minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        guard maxX - minX >= 10, maxY - minY >= 10 else { return -1 }
        // Rows across the middle 40% of columns (clear of the sleeves).
        let x0 = minX + (maxX - minX) * 3 / 10, x1 = minX + (maxX - minX) * 7 / 10
        return peak(profile(count: maxY - minY + 1, across: x1 - x0 + 1) { lightness[(minY + $0) * width + x0 + $1] })
    }

    /// The mean of each line's garment pixels (lines with fewer than four left out).
    static func profile(count: Int, across: Int, _ value: (Int, Int) -> Double) -> [Double] {
        var out: [Double] = []
        for i in 0..<count {
            var sum = 0.0, n = 0
            for j in 0..<across { let v = value(i, j); if !v.isNaN { sum += v; n += 1 } }
            if n > 3 { out.append(sum / Double(n)) }
        }
        return out
    }

    /// The profile's first autocorrelation peak after it first goes
    /// negative (up to half the profile); −1 when there is none or the
    /// profile barely moves. The FIRST peak, not the highest: the highest
    /// lifted a print (0.27), trousers (0.26) and trainers (0.22) to within
    /// reach of the striped top (0.44).
    static func peak(_ profile: [Double]) -> Double {
        guard profile.count >= 8, let low = profile.min(), let high = profile.max(), high - low >= minimumSwing else {
            return -1
        }
        let mean = profile.reduce(0, +) / Double(profile.count)
        let v = profile.map { $0 - mean }
        let energy = v.reduce(0) { $0 + $1 * $1 }
        guard energy > 1e-9 else { return -1 }
        var ac: [Double] = [1]
        for lag in 1..<(profile.count / 2) {
            var s = 0.0
            for i in 0..<(v.count - lag) { s += v[i] * v[i + lag] }
            ac.append(s / energy)
        }
        var crossed = false
        for lag in 1..<ac.count {
            if ac[lag] < 0 { crossed = true }
            if crossed, lag + 1 < ac.count, ac[lag] > ac[lag - 1], ac[lag] >= ac[lag + 1] { return ac[lag] }
        }
        return -1
    }
}
