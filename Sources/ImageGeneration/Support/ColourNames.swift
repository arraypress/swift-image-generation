//
//  ColourNames.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  A garment's colour in words, read from its pixels: the main colours
//  (k-means in OKLab, seeded deterministically), each named by the nearest
//  of a small table of everyday names. Measured on the dressing test: a
//  one-colour garment came out closer with its colour named (a mustard
//  jacket ΔE 3.5 against 5.4), but naming two colours without the pattern
//  ("red and white", no "striped") turned a striped top plain red — so a
//  caller should name a garment's colour only when it has one.
//

import Foundation

enum ColourNames {

    /// OKLab, ×100 (L 0–100; a, b about ±40).
    struct Lab: Equatable { var l, a, b: Double }

    /// sRGB (0–255) to OKLab ×100.
    static func lab(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> Lab {
        func linear(_ c: UInt8) -> Double {
            let v = Double(c) / 255
            return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        let rl = linear(r), gl = linear(g), bl = linear(b)
        let l = cbrt(0.4122214708 * rl + 0.5363325363 * gl + 0.0514459929 * bl)
        let m = cbrt(0.2119034982 * rl + 0.6806995451 * gl + 0.1073969566 * bl)
        let s = cbrt(0.0883024619 * rl + 0.2817188376 * gl + 0.6299787005 * bl)
        return Lab(l: (0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s) * 100,
                   a: (1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s) * 100,
                   b: (0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s) * 100)
    }

    static func distance(_ x: Lab, _ y: Lab) -> Double {
        ((x.l - y.l) * (x.l - y.l) + (x.a - y.a) * (x.a - y.a) + (x.b - y.b) * (x.b - y.b)).squareRoot()
    }

    /// Everyday colour names and an sRGB value for each.
    static let table: [(name: String, r: UInt8, g: UInt8, b: UInt8)] = [
        ("black", 20, 20, 20), ("charcoal", 60, 62, 66), ("grey", 128, 128, 128), ("light grey", 200, 200, 200),
        ("white", 250, 250, 250), ("cream", 243, 235, 210), ("beige", 215, 195, 160), ("tan", 190, 150, 105),
        ("camel", 193, 154, 107), ("brown", 120, 75, 45), ("chocolate brown", 75, 45, 30),
        ("red", 200, 25, 35), ("burgundy", 110, 20, 40), ("pink", 240, 150, 180), ("hot pink", 230, 50, 140),
        ("coral", 245, 120, 95), ("orange", 240, 120, 30), ("rust", 170, 75, 35),
        ("mustard yellow", 215, 165, 40), ("yellow", 245, 215, 50), ("olive", 110, 110, 50),
        ("khaki", 180, 170, 120), ("sage green", 150, 170, 135), ("green", 40, 150, 70),
        ("bottle green", 25, 80, 50), ("teal", 20, 120, 120), ("light blue", 150, 190, 230),
        ("denim blue", 90, 120, 160), ("blue", 40, 90, 200), ("cobalt blue", 0, 70, 170), ("navy", 25, 35, 75),
        ("purple", 110, 50, 140), ("lavender", 185, 165, 220),
    ]

    static let tableLab: [(name: String, lab: Lab)] = table.map { ($0.name, lab($0.r, $0.g, $0.b)) }

    /// Chroma (×100) under which a colour is a neutral — white, grey, black.
    static let neutralChroma = 3.0

    static func chroma(_ colour: Lab) -> Double { (colour.a * colour.a + colour.b * colour.b).squareRoot() }

    /// The nearest name to `colour`, among the neutrals for a neutral colour
    /// and among the hues otherwise — so a near-white is "white", never
    /// "cream", and dark bottle-green wool (chroma 4.7) is green, never
    /// "charcoal", which plain nearest-colour gave.
    static func name(_ colour: Lab) -> String {
        let neutral = chroma(colour) < neutralChroma
        let pool = tableLab.filter { (chroma($0.lab) < neutralChroma) == neutral }
        return pool.min { distance($0.lab, colour) < distance($1.lab, colour) }!.name
    }

    /// The main colours of `colours`, as (centre, share 0…1), largest first:
    /// k-means with k up to 3, seeded at lightness quantiles so the result is
    /// the same every run; clusters closer than 12 are merged.
    static func clusters(_ colours: [Lab]) -> [(centre: Lab, share: Double)] {
        guard !colours.isEmpty else { return [] }
        let sorted = colours.map(\.l).sorted()
        var centres = [0.15, 0.5, 0.85].map { q -> Lab in
            let l = sorted[min(sorted.count - 1, Int(Double(sorted.count) * q))]
            return colours.min { abs($0.l - l) < abs($1.l - l) }!
        }
        var counts = [Int](repeating: 0, count: centres.count)
        for _ in 0..<12 {
            var sums = [Lab](repeating: Lab(l: 0, a: 0, b: 0), count: centres.count)
            counts = [Int](repeating: 0, count: centres.count)
            for colour in colours {
                let j = centres.indices.min { distance(centres[$0], colour) < distance(centres[$1], colour) }!
                sums[j].l += colour.l; sums[j].a += colour.a; sums[j].b += colour.b; counts[j] += 1
            }
            for j in centres.indices where counts[j] > 0 {
                let n = Double(counts[j])
                centres[j] = Lab(l: sums[j].l / n, a: sums[j].a / n, b: sums[j].b / n)
            }
        }
        var found = centres.indices.filter { counts[$0] > 0 }.map { (centre: centres[$0], count: counts[$0]) }
        found.sort { $0.count > $1.count }
        var merged: [(centre: Lab, count: Int)] = []
        for cluster in found {
            if let i = merged.firstIndex(where: { distance($0.centre, cluster.centre) < 12 }) {
                let n = Double(merged[i].count + cluster.count), a = Double(merged[i].count), b = Double(cluster.count)
                let x = merged[i].centre, y = cluster.centre
                merged[i] = (Lab(l: (x.l * a + y.l * b) / n, a: (x.a * a + y.a * b) / n, b: (x.b * a + y.b * b) / n),
                             merged[i].count + cluster.count)
            } else {
                merged.append(cluster)
            }
        }
        return merged.map { ($0.centre, Double($0.count) / Double(colours.count)) }
    }

    /// The colour of `colours` in words — "mustard yellow", "red and white" —
    /// naming every main colour holding at least `minimumShare` of them (two
    /// at most); `nil` when there are none.
    static func describe(_ colours: [Lab], minimumShare: Double = 0.2) -> String? {
        var names: [String] = []
        for cluster in clusters(colours) where cluster.share >= minimumShare {
            let name = name(cluster.centre)
            if !names.contains(name) { names.append(name) }
            if names.count == 2 { break }
        }
        return names.isEmpty ? nil : names.joined(separator: " and ")
    }
}
