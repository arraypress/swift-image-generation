//
//  SideBySide.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  One picture in instead of two. FLUX.2 Klein shares its reference room
//  between the pictures it is given, so an edit with a reference sees each
//  at a fraction of its resolution — and fine patterns die: a striped top
//  put on a person through `--edit` + `--ref` came back with half its white
//  bands washed pink (measured on generated fashion photos, 2026-10-14:
//  2-cluster lightness gap 27 against the reference's 40, colour within
//  ΔE 10 of the reference's for 65% of the garment's pixels). The same top
//  drawn from the reference alone was crisp. So the photo's region and the
//  garment go in as ONE picture — the region on the left, the garment on
//  white on the right — and the edit is asked to dress the left from the
//  right: the stripes came back crisp (gap 37, 88% on the reference's
//  colours), and the left panel goes back through the masks as any masked
//  edit does.
//

import CoreGraphics
import Foundation

enum SideBySide {

    /// The left panel's share of the canvas: a torso with its arms is about
    /// 0.62 as wide as it is tall, measured on the masks of three generated
    /// fashion photos.
    static let panelShare = 0.625

    /// Room left around the masks inside the panel, as a share of their box.
    static let margin = 0.15

    /// The layout for `masks` on a `width × height` photo, for a model that
    /// draws `canvas × canvas`.
    static func plan(_ masks: [RegionMask], imageWidth width: Int, imageHeight height: Int,
                     canvas: Int) -> SideBySidePlan? {
        guard let square = MaskedComposite.plan(masks, imageWidth: width, imageHeight: height) else { return nil }
        var minX = Int.max, minY = Int.max, maxX = -1, maxY = -1
        for mask in masks {
            let pixels = MaskedComposite.fitted(mask, width: width, height: height)
            for y in 0..<height {
                for x in 0..<width where pixels[y * width + x] > 127 {
                    minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
                }
            }
        }
        guard maxX >= 0 else { return nil }
        let panelWidth = Int((Double(canvas) * panelShare).rounded())
        let want = Double(panelWidth) / Double(canvas)
        var w = Double(maxX - minX + 1) * (1 + 2 * margin), h = Double(maxY - minY + 1) * (1 + 2 * margin)
        if w / h < want { w = h * want } else { h = w / want }
        let cx = Double(minX + maxX + 1) / 2, cy = Double(minY + maxY + 1) / 2
        return SideBySidePlan(panel: CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h),
                              panelWidth: panelWidth, canvas: canvas, square: square)
    }

    /// The one picture the model is given: the photo's panel on the left,
    /// `thing` fitted on white on the right.
    static func canvas(_ original: PixelRaster, thing: CGImage, plan: SideBySidePlan) -> CGImage? {
        let size = plan.canvas
        var bytes = [UInt8](repeating: 255, count: size * size * 4)
        // The panel, sampled from the photo with edges repeated past its
        // border; a photo larger than the panel is first scaled down with
        // proper filtering, so a bilinear sample does not alias.
        var source = original, factor = 1.0
        let reduction = plan.panel.height / Double(size)
        if reduction > 1.25, let whole = original.image(), let smaller = PixelRaster.render(
            whole, width: max(1, Int(Double(original.width) / reduction)),
            height: max(1, Int(Double(original.height) / reduction)), colorSpace: original.colorSpace) {
            source = smaller
            factor = Double(original.width) / Double(smaller.width)
        }
        let scaleX = plan.panel.width / Double(plan.panelWidth), scaleY = plan.panel.height / Double(size)
        for y in 0..<size {
            for x in 0..<plan.panelWidth {
                let sx = (plan.panel.minX + (Double(x) + 0.5) * scaleX) / factor - 0.5
                let sy = (plan.panel.minY + (Double(y) + 0.5) * scaleY) / factor - 0.5
                let pixel = sample(source, x: sx, y: sy)
                let o = (y * size + x) * 4
                bytes[o] = pixel.0; bytes[o + 1] = pixel.1; bytes[o + 2] = pixel.2; bytes[o + 3] = 255
            }
        }
        let panel = PixelRaster(width: size, height: size, bytes: bytes, colorSpace: original.colorSpace)
        guard let picture = panel.image() else { return nil }
        // The thing, fitted into the right panel, centred, on white.
        let room = Double(size - plan.panelWidth)
        let fit = min(room / Double(thing.width), Double(size) / Double(thing.height))
        let w = Double(thing.width) * fit, h = Double(thing.height) * fit
        let rect = CGRect(x: Double(plan.panelWidth) + (room - w) / 2, y: (Double(size) - h) / 2, width: w, height: h)
        return draw(thing, over: picture, in: rect, colorSpace: original.colorSpace)?.image()
    }

    /// The edited square for ``MaskedComposite``: the original's square with
    /// the edit's left panel drawn back over the part of it the panel shows.
    /// `panel` is the left panel of the edit, at any size.
    static func square(_ original: PixelRaster, panel: CGImage, plan: SideBySidePlan) -> CGImage? {
        let square = plan.square
        guard let base = MaskedComposite.source(original, plan: square, size: square.side) else { return nil }
        let rect = CGRect(x: plan.panel.minX - Double(square.x), y: plan.panel.minY - Double(square.y),
                          width: plan.panel.width, height: plan.panel.height)
        return draw(panel, over: base, in: rect, colorSpace: original.colorSpace)?.image()
    }

    /// `image` drawn over `base` into `rect` (top-left origin), high-quality.
    static func draw(_ image: CGImage, over base: CGImage, in rect: CGRect, colorSpace: CGColorSpace) -> PixelRaster? {
        let width = base.width, height = base.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let ok: Bool = bytes.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                                          bytesPerRow: width * 4, space: colorSpace,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.interpolationQuality = .high
            context.draw(base, in: CGRect(x: 0, y: 0, width: width, height: height))
            // Core Graphics counts from the bottom.
            context.draw(image, in: CGRect(x: rect.minX, y: Double(height) - rect.maxY, width: rect.width, height: rect.height))
            return true
        }
        return ok ? PixelRaster(width: width, height: height, bytes: bytes, colorSpace: colorSpace) : nil
    }

    /// A bilinear sample of `raster` at (x, y), edges repeated.
    static func sample(_ raster: PixelRaster, x: Double, y: Double) -> (UInt8, UInt8, UInt8) {
        let w = raster.width, h = raster.height
        let cx = min(max(x, 0), Double(w - 1)), cy = min(max(y, 0), Double(h - 1))
        let x0 = Int(cx), y0 = Int(cy), x1 = min(x0 + 1, w - 1), y1 = min(y0 + 1, h - 1)
        let fx = cx - Double(x0), fy = cy - Double(y0)
        func at(_ px: Int, _ py: Int, _ c: Int) -> Double { Double(raster.bytes[(py * w + px) * 4 + c]) }
        func channel(_ c: Int) -> UInt8 {
            let top = at(x0, y0, c) * (1 - fx) + at(x1, y0, c) * fx
            let bottom = at(x0, y1, c) * (1 - fx) + at(x1, y1, c) * fx
            return UInt8(min(255, max(0, (top * (1 - fy) + bottom * fy).rounded())))
        }
        return (channel(0), channel(1), channel(2))
    }
}
