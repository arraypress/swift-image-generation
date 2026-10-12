//
//  FacePlan.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The geometry of a face fix, as pure functions: which faces are small
//  enough to need it, the square to redraw around each, and the soft oval
//  that goes back. Vision's face box runs from the brows to the chin, so the
//  oval is taller than the box and reaches up to the hairline.
//

import CoreGraphics
import Foundation

enum FacePlan {

    /// Whether a face is worth redrawing: small, and Vision sure of it.
    static func needsFix(_ face: DetectedFace, imageWidth: Int, imageHeight: Int, options: FaceFixOptions) -> Bool {
        let longer = Double(max(imageWidth, imageHeight))
        guard longer > 0, face.confidence >= options.minimumConfidence, face.box.width >= 8 else { return false }
        return Double(max(face.box.width, face.box.height)) / longer <= options.largestFace
    }

    /// The square to redraw: `context` times the face, centred on it, inside
    /// the picture where the picture is large enough.
    static func plan(for box: CGRect, imageWidth: Int, imageHeight: Int, context: Double) -> MaskedEditPlan {
        let face = Double(max(box.width, box.height))
        let side = min(max(Int((face * context).rounded()), 64), max(imageWidth, imageHeight))
        func place(_ centre: Double, _ length: Int) -> Int {
            side <= length ? min(max(Int(centre.rounded()) - side / 2, 0), length - side) : (length - side) / 2
        }
        return MaskedEditPlan(x: place(Double(box.midX), imageWidth), y: place(Double(box.midY), imageHeight),
                              side: side, imageWidth: imageWidth, imageHeight: imageHeight)
    }

    /// The oval that goes back: the face box widened a little and raised to
    /// take in the forehead, as a replacing mask at the picture's size.
    static func mask(for box: CGRect, imageWidth: Int, imageHeight: Int) -> RegionMask {
        let centreX = Double(box.midX), centreY = Double(box.midY) - Double(box.height) * 0.08
        let radiusX = Double(box.width) * 0.62, radiusY = Double(box.height) * 0.72
        var pixels = [UInt8](repeating: 0, count: imageWidth * imageHeight)
        let top = max(0, Int(centreY - radiusY)), bottom = min(imageHeight - 1, Int(centreY + radiusY))
        let left = max(0, Int(centreX - radiusX)), right = min(imageWidth - 1, Int(centreX + radiusX))
        if top <= bottom, left <= right {
            for y in top...bottom {
                let dy = (Double(y) + 0.5 - centreY) / radiusY
                for x in left...right {
                    let dx = (Double(x) + 0.5 - centreX) / radiusX
                    if dx * dx + dy * dy <= 1 { pixels[y * imageWidth + x] = 255 }
                }
            }
        }
        return RegionMask(name: "face", width: imageWidth, height: imageHeight, pixels: pixels, replaces: true)
    }

    /// What the edit model is asked for. FLUX.2 Klein edits by instruction,
    /// so the picture's whole prompt is the wrong thing to send: given "a
    /// woman in a coat in an alley" with the face's square, it drew a whole
    /// new small woman in a coat inside the oval. The instruction names only
    /// who it is — the prompt's first part — and says what to keep.
    /// With references, it asks for the face from them: a redraw otherwise
    /// invents a stranger's face, which would undo a likeness.
    static func instruction(for prompt: String, withReferences: Bool = false) -> String {
        let who = subject(of: prompt)
        let likeness = withReferences ? " It is the same person as in the other pictures; keep their likeness." : ""
        return "Redraw only the face\(who.isEmpty ? "" : " of \(who)") as a natural, detailed face with clear, "
            + "sharp eyes.\(likeness) Keep the framing, pose, head size, hair, clothes, background and lighting exactly the same."
    }

    /// Who a prompt is about: its first comma-separated part, briefly.
    static func subject(of prompt: String) -> String {
        let first = prompt.split(separator: ",", maxSplits: 1).first.map(String.init) ?? ""
        let trimmed = first.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count <= 120 ? trimmed : ""
    }
}
