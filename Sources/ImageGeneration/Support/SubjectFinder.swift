//
//  SubjectFinder.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The main subject of a picture, from Vision's foreground instance mask —
//  the same lift `cutout` does with no model to download. Every instance it
//  finds is kept: two shoes are one subject.
//

import CoreGraphics
import CoreVideo
import Foundation
import Vision

enum SubjectFinder {

    /// The subject's mask at the picture's size (0–255), or `nil` when
    /// Vision finds no foreground.
    static func mask(in image: CGImage) throws(ImageGenerationError) -> [UInt8]? {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: image)
        let buffer: CVPixelBuffer
        do {
            try handler.perform([request])
            guard let result = request.results?.first, !result.allInstances.isEmpty else { return nil }
            buffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
        } catch {
            throw .generationFailed("finding the picture's subject failed: \(error.localizedDescription)")
        }
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        let width = CVPixelBufferGetWidth(buffer), height = CVPixelBufferGetHeight(buffer)
        guard width == image.width, height == image.height,
              CVPixelBufferGetPixelFormatType(buffer) == kCVPixelFormatType_OneComponent32Float,
              let base = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let row = CVPixelBufferGetBytesPerRow(buffer)
        var out = [UInt8](repeating: 0, count: width * height)
        for y in 0..<height {
            let line = (base + y * row).assumingMemoryBound(to: Float32.self)
            for x in 0..<width { out[y * width + x] = UInt8(max(0, min(255, (line[x] * 255).rounded()))) }
        }
        return out
    }
}
