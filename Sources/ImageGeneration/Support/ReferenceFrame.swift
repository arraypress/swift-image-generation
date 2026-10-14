//
//  ReferenceFrame.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The arithmetic of framing a reference picture around its subject. FLUX
//  sees each picture in at a fraction of its resolution once two or more go
//  in (the reference room is shared), so a product shot whose garment fills
//  a third of the frame reaches the model as a few hundred pixels of
//  garment, and fine patterns die: a striped top's white share fell from 31%
//  in the reference to 0.2% on the person. Cut tight around the garment and
//  set on white, the same top kept 19.7%.
//
//  Only a picture on a plain background is framed: its border must be one
//  colour (a studio sweep, a white page). A scene, a room or a painting —
//  where the whole picture is the point — is left alone.
//

import CoreGraphics
import Foundation

enum ReferenceFrame {

    /// The box of every mask pixel at or above 128, in pixels, top-left
    /// origin; `nil` for an empty mask.
    static func bounds(_ mask: [UInt8], width: Int, height: Int) -> (x: Int, y: Int, width: Int, height: Int)? {
        var minX = width, minY = height, maxX = -1, maxY = -1
        for y in 0..<height {
            let row = y * width
            for x in 0..<width where mask[row + x] >= 128 {
                minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        guard maxX >= 0 else { return nil }
        return (minX, minY, maxX - minX + 1, maxY - minY + 1)
    }

    /// How far the picture's border strays from one colour: the mean OKLab
    /// distance (×100) of the outer `band` of pixels from their average.
    /// A white or grey studio backdrop measures a few units; a photo of a
    /// scene, tens.
    static func borderSpread(_ raster: PixelRaster, band: Double = 0.03) -> Double {
        let w = raster.width, h = raster.height
        let edge = max(1, Int(Double(min(w, h)) * band))
        var colours: [ColourNames.Lab] = []
        let step = max(1, min(w, h) / 256)
        for y in stride(from: 0, to: h, by: step) {
            for x in stride(from: 0, to: w, by: step) where x < edge || y < edge || x >= w - edge || y >= h - edge {
                let i = (y * w + x) * 4
                colours.append(ColourNames.lab(raster.bytes[i], raster.bytes[i + 1], raster.bytes[i + 2]))
            }
        }
        guard !colours.isEmpty else { return 0 }
        let n = Double(colours.count)
        let mean = ColourNames.Lab(l: colours.map(\.l).reduce(0, +) / n, a: colours.map(\.a).reduce(0, +) / n,
                                   b: colours.map(\.b).reduce(0, +) / n)
        return colours.map { ColourNames.distance($0, mean) }.reduce(0, +) / n
    }

    /// The masked thing on white, centred, `padding` (a share of its longer
    /// side) clear of each edge: in a square when `square`, else in its own
    /// box's shape. Pixels are blended by the mask, so a soft edge stays soft.
    static func onWhite(_ raster: PixelRaster, mask: [UInt8], padding: Double, square: Bool = true) -> PixelRaster? {
        let w = raster.width, h = raster.height
        guard let box = bounds(mask, width: w, height: h) else { return nil }
        let pad = Int((Double(max(box.width, box.height)) * padding).rounded())
        let outW = square ? max(box.width, box.height) + 2 * pad : box.width + 2 * pad
        let outH = square ? outW : box.height + 2 * pad
        var out = PixelRaster(width: outW, height: outH, bytes: [UInt8](repeating: 255, count: outW * outH * 4),
                              colorSpace: raster.colorSpace)
        let dx = (outW - box.width) / 2 - box.x, dy = (outH - box.height) / 2 - box.y
        for y in box.y..<(box.y + box.height) {
            for x in box.x..<(box.x + box.width) {
                let i = y * w + x
                let alpha = Double(mask[i]) / 255
                guard alpha > 0 else { continue }
                let o = ((y + dy) * outW + x + dx) * 4
                for c in 0..<3 {
                    out.bytes[o + c] = UInt8((Double(raster.bytes[i * 4 + c]) * alpha + 255 * (1 - alpha)).rounded())
                }
            }
        }
        return out
    }

    /// `raster` with everything outside `mask` turned pure white, blended
    /// by the mask; the same size.
    static func whitened(_ raster: PixelRaster, mask: [UInt8]) -> PixelRaster {
        var out = raster
        for i in 0..<min(mask.count, raster.width * raster.height) {
            let alpha = Double(mask[i]) / 255
            for c in 0..<3 {
                out.bytes[i * 4 + c] = UInt8((Double(raster.bytes[i * 4 + c]) * alpha + 255 * (1 - alpha)).rounded())
            }
            out.bytes[i * 4 + 3] = 255
        }
        return out
    }

    /// Whether framing is worth doing: a plain border, and a subject that
    /// does not fill the picture already (its box's longer side under
    /// `fill` of the picture's).
    static func worthFraming(borderSpread: Double, box: (x: Int, y: Int, width: Int, height: Int),
                             width: Int, height: Int, plainBorder: Double = plainBorderLimit,
                             fill: Double = 0.9) -> Bool {
        borderSpread <= plainBorder
            && Double(max(box.width, box.height)) < fill * Double(max(width, height))
    }

    /// The border spread at or under which a background counts as plain.
    static let plainBorderLimit = 4.0
}
