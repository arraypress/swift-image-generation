//
//  ImageGenerator.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Pictures from words on this machine, through Apple's Core AI diffusion
//  pipeline. One export loads once and serves every picture; the first load
//  of a new export also compiles it for this Mac's GPU (Core AI caches that
//  per executable under ~/Library/Caches/coreai-cache), which is most of a
//  first run's time — 46.6 s to the first FLUX picture, then 19 s each on an
//  M3 Max.
//

import CoreAIDiffusionPipeline
import CoreGraphics
import Foundation

/// Makes pictures with FLUX.2 Klein 4B or SANA Sprint 1.6B.
///
/// ```swift
/// let generator = try await ImageGenerator(bundle: fluxFolder)
/// let pictures = try await generator.generate("a red bicycle against a blue door", seed: 7)
/// try pictures[0].write(to: URL(fileURLWithPath: "bike.png"), generator: "my app")
/// ```
public final class ImageGenerator: Sendable {

    /// The most pictures one call makes.
    public static let maximumCount = 16

    /// The model the export holds.
    public let model: GenerationModel

    /// The export folder.
    public let bundle: URL

    /// The pictures' width and height, from the export.
    public let size: (width: Int, height: Int)

    /// Whether ``edit(_:_:seed:strength:allowText:)`` can run: FLUX.2 Klein
    /// with its editing parts (`Transformer_img2img_full`, `VAEEncoder`)
    /// beside the rest.
    public let supportsEditing: Bool

    private let pipeline: FlowTransformerPipeline
    private let defaults: Defaults

    /// The step count, guidance and scale factors the export was made for.
    private struct Defaults: Sendable {
        let steps: Int
        let guidance: Float
        let encoderScale: Float
        let decoderScale: Float
        let decoderShift: Float
        let lazy: Bool
    }

    /// Loads an export.
    ///
    /// - Parameters:
    ///   - bundle: The folder Apple's exporter wrote — `metadata.json` and the
    ///     `.aimodel` files.
    ///   - lowMemory: Load each part only while it is needed. Measured for
    ///     FLUX: peak 4.6 GB instead of 8.6 GB.
    /// - Throws: ``ImageGenerationError``.
    public init(bundle: URL, lowMemory: Bool = false) async throws(ImageGenerationError) {
        let model = try BundleIdentity.model(at: bundle)
        let pipeline: FlowTransformerPipeline
        let config: DiffusionConfig
        do {
            config = try DiffusionBundle(at: bundle).config
            pipeline = try await FlowTransformerPipeline(from: bundle)
        } catch {
            throw .loadFailed(String(describing: error))
        }
        self.model = model
        self.bundle = bundle
        self.pipeline = pipeline
        self.size = pipeline.defaultImageSize
        // Editing works on a square export only: FLUX's reference tokens are traced square.
        self.supportsEditing = model.supportsEditing && pipeline.supportsImageToImage && !pipeline.isNonSquare
        self.defaults = Defaults(
            steps: config.defaultSteps ?? DiffusionDefaults.Runner.steps,
            guidance: config.defaultGuidanceScale ?? DiffusionDefaults.Runner.guidanceScale,
            encoderScale: config.encoderScaleFactor ?? DiffusionDefaults.Image.scaleFactor,
            decoderScale: config.decoderScaleFactor ?? DiffusionDefaults.Image.scaleFactor,
            decoderShift: config.decoderShiftFactor ?? DiffusionDefaults.Image.decoderShiftFactor,
            lazy: lowMemory)
    }

    /// Makes `count` pictures of `prompt`.
    ///
    /// - Parameters:
    ///   - prompt: What to draw.
    ///   - seed: The first seed; random when `nil`. Picture *n* uses `seed + n`.
    ///   - count: How many, 1…``maximumCount``.
    ///   - allowText: Leave the prompt alone. By default "no text, no letters,
    ///     no typography" is appended, because both models invent and misspell
    ///     lettering — add real text afterwards instead.
    ///   - progress: Called after each denoising step with (step, steps).
    /// - Returns: The pictures, in seed order, at the export's ``size``.
    /// - Throws: ``ImageGenerationError``; `.cancelled` when the task is.
    public func generate(_ prompt: String, seed: UInt32? = nil, count: Int = 1, allowText: Bool = false,
                         progress: (@Sendable (Int, Int) -> Void)? = nil) async throws(ImageGenerationError) -> [GeneratedImage] {
        let text = try PromptText.validated(prompt)
        guard (1...Self.maximumCount).contains(count) else { throw .invalidCount(count) }
        let sent = PromptText.composed(text, allowText: allowText)
        var pictures: [GeneratedImage] = []
        for picture in SeedPlan.seeds(start: seed, count: count) {
            let config = configuration(prompt: sent, seed: picture, startingImage: nil, strength: 1)
            let (image, seconds) = try await run(config, progress: progress)
            pictures.append(GeneratedImage(image: image, seed: picture, model: model, prompt: text,
                                           promptSent: sent, edited: false, seconds: seconds))
        }
        return pictures
    }

    /// Changes a picture as `instruction` says — FLUX.2 Klein only.
    ///
    /// The source is cropped to its centred square first (the model works on
    /// a 1024 square and would otherwise stretch it).
    ///
    /// - Parameters:
    ///   - image: The picture to change.
    ///   - instruction: What to change, e.g. "make it night".
    ///   - seed: Random when `nil`.
    ///   - strength: How far from the source, 0…1. 0.85 is Apple's default:
    ///     0.8–0.9 for changes of content, 0.5–0.75 for style or texture.
    ///   - allowText: As for ``generate(_:seed:count:allowText:progress:)``.
    ///   - progress: As for ``generate(_:seed:count:allowText:progress:)``.
    /// - Throws: ``ImageGenerationError``; `.editingUnavailable` for SANA or
    ///   when the editing parts are not installed.
    public func edit(_ image: CGImage, _ instruction: String, seed: UInt32? = nil, strength: Float = 0.85,
                     allowText: Bool = false,
                     progress: (@Sendable (Int, Int) -> Void)? = nil) async throws(ImageGenerationError) -> GeneratedImage {
        guard model.supportsEditing else {
            throw .editingUnavailable("\(model.displayName) cannot edit pictures; FLUX.2 Klein 4B can")
        }
        guard supportsEditing else {
            throw .editingUnavailable(size.width != size.height
                ? "Editing works on the square export only; this one is \(size.width)×\(size.height)"
                : "This FLUX.2 Klein export has no editing parts (Transformer_img2img_full, VAEEncoder)")
        }
        guard strength > 0, strength <= 1 else { throw .invalidPrompt("Strength is more than 0 and at most 1") }
        let text = try PromptText.validated(instruction)
        let sent = PromptText.composed(text, allowText: allowText)
        let picture = SeedPlan.seeds(start: seed, count: 1)[0]
        let config = configuration(prompt: sent, seed: picture, startingImage: SquareCrop.centred(image), strength: strength)
        let (result, seconds) = try await run(config, progress: progress)
        return GeneratedImage(image: result, seed: picture, model: model, prompt: text,
                              promptSent: sent, edited: true, seconds: seconds)
    }

    // MARK: - Plumbing

    private func configuration(prompt: String, seed: UInt32, startingImage: CGImage?,
                               strength: Float) -> PipelineConfiguration {
        PipelineConfiguration(
            prompt: prompt, seed: seed,
            stepCount: defaults.steps, guidanceScale: defaults.guidance,
            schedulerType: .discreteFlow,
            startingImage: startingImage, strength: strength,
            encoderScaleFactor: defaults.encoderScale,
            decoderScaleFactor: defaults.decoderScale,
            decoderShiftFactor: defaults.decoderShift,
            lazyModelLoading: defaults.lazy)
    }

    private func run(_ config: PipelineConfiguration,
                     progress: (@Sendable (Int, Int) -> Void)?) async throws(ImageGenerationError) -> (CGImage, Double) {
        let clock = ContinuousClock()
        let started = clock.now
        let images: [CGImage]
        do {
            images = try await pipeline.generateImages(configuration: config) { step in
                progress?(step.step, step.totalSteps)
                return !Task.isCancelled
            }.images
        } catch {
            if Task.isCancelled { throw .cancelled }
            throw .generationFailed(String(describing: error))
        }
        if Task.isCancelled { throw .cancelled }
        guard let image = images.first else { throw .generationFailed("no picture came back") }
        let elapsed: Duration = clock.now - started
        let seconds = Double(elapsed.components.seconds) + Double(elapsed.components.attoseconds) / 1e18
        return (image, (seconds * 100).rounded() / 100)
    }
}
