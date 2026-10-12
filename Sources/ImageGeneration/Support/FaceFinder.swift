//
//  FaceFinder.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Faces and how well they are drawn, from Vision. Capture quality is the
//  measure the face fix judges itself by: on the sample that started this,
//  a melted 71 px face scored 0.28 where clean faces the same size scored
//  0.43–0.54.
//

import CoreGraphics
import Foundation
import Vision

enum FaceFinder {

    /// Every face in `image`, with its capture quality, largest first.
    static func faces(in image: CGImage) throws(ImageGenerationError) -> [DetectedFace] {
        let rectangles = VNDetectFaceRectanglesRequest()
        let quality = VNDetectFaceCaptureQualityRequest()
        do {
            try VNImageRequestHandler(cgImage: image).perform([rectangles])
            let found = rectangles.results ?? []
            guard !found.isEmpty else { return [] }
            quality.inputFaceObservations = found
            try VNImageRequestHandler(cgImage: image).perform([quality])
        } catch {
            throw .generationFailed("finding faces failed: \(error.localizedDescription)")
        }
        let width = Double(image.width), height = Double(image.height)
        return (quality.results ?? []).map { face in
            let b = face.boundingBox
            let box = CGRect(x: b.minX * width, y: (1 - b.maxY) * height, width: b.width * width, height: b.height * height)
            return DetectedFace(box: box.integral, confidence: face.confidence, quality: face.faceCaptureQuality)
        }.sorted { $0.box.width * $0.box.height > $1.box.width * $1.box.height }
    }

    /// The face in `faces` nearest `box`'s centre, if any lies within half
    /// its size of it.
    static func nearest(to box: CGRect, in faces: [DetectedFace]) -> DetectedFace? {
        let reach = max(box.width, box.height) / 2
        return faces.map { (face: $0, distance: hypot($0.box.midX - box.midX, $0.box.midY - box.midY)) }
            .filter { $0.distance <= reach }
            .min { $0.distance < $1.distance }?.face
    }
}
