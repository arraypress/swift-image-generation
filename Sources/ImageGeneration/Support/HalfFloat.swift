//
//  HalfFloat.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Half-float conversions through vImage, which every Apple platform has —
//  Swift's `Float16` is missing on Intel Macs, and LoRA matrices run to tens
//  of millions of values.
//

import Accelerate
import Foundation

enum HalfFloat {

    /// Little-endian F32 bytes as floats.
    static func floats(fromF32 bytes: Data) -> [Float] {
        var out = [Float](repeating: 0, count: bytes.count / 4)
        out.withUnsafeMutableBytes { dst in _ = bytes.copyBytes(to: dst) }
        return out
    }

    /// Little-endian BF16 bytes as floats: the top half of an F32's bits.
    static func floats(fromBF16 bytes: Data) -> [Float] {
        let count = bytes.count / 2
        var out = [Float](repeating: 0, count: count)
        bytes.withUnsafeBytes { raw in
            for i in 0..<count {
                let bits = UInt32(raw[2 * i]) | (UInt32(raw[2 * i + 1]) << 8)
                out[i] = Float(bitPattern: bits << 16)
            }
        }
        return out
    }

    /// Little-endian F16 bytes as floats.
    static func floats(fromHalf bytes: Data) -> [Float] {
        let count = bytes.count / 2
        var out = [Float](repeating: 0, count: count)
        guard count > 0 else { return out }
        var input = Data(bytes)
        input.withUnsafeMutableBytes { src in
            out.withUnsafeMutableBytes { dst in
                var s = vImage_Buffer(data: src.baseAddress, height: 1, width: vImagePixelCount(count), rowBytes: count * 2)
                var d = vImage_Buffer(data: dst.baseAddress, height: 1, width: vImagePixelCount(count), rowBytes: count * 4)
                _ = vImageConvert_Planar16FtoPlanarF(&s, &d, 0)
            }
        }
        return out
    }

    /// Floats as little-endian F16 bytes, rounded to nearest.
    static func fromFloats(_ values: [Float]) -> Data {
        var out = Data(count: values.count * 2)
        guard !values.isEmpty else { return out }
        var input = values
        input.withUnsafeMutableBytes { src in
            out.withUnsafeMutableBytes { dst in
                var s = vImage_Buffer(data: src.baseAddress, height: 1, width: vImagePixelCount(values.count), rowBytes: values.count * 4)
                var d = vImage_Buffer(data: dst.baseAddress, height: 1, width: vImagePixelCount(values.count), rowBytes: values.count * 2)
                _ = vImageConvert_PlanarFtoPlanar16F(&s, &d, 0)
            }
        }
        return out
    }
}
