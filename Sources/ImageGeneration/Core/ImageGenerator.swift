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

import CoreAI
import CoreAIDiffusionPipeline
import StdoutSilencer
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

    /// The most pictures FLUX.2 Klein takes in, the edited one included: the
    /// traced reference route holds four quarter-size grids.
    public static let maximumReferences = 4

    /// The model the export holds.
    public let model: GenerationModel

    /// The export folder.
    public let bundle: URL

    /// The pictures' width and height, from the export.
    public let size: (width: Int, height: Int)

    /// Whether ``edit(_:_:seed:strength:allowText:steps:references:person:progress:)``
    /// can run: FLUX.2 Klein with an editing function for this export's shape and a
    /// `VAEEncoder` at that shape.
    public let supportsEditing: Bool

    /// The export's LoRA slot (`slot.json`), or `nil` for a plain export. With
    /// one, ``generate(_:seed:count:allowText:steps:references:person:progress:)``
    /// can draw a ``Person``; without a person it draws exactly as a plain export.
    public let loraSlot: LoRASlotLayout?

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
            // Core AI's load prints compiler warnings on stdout, where a tool's JSON goes.
            pipeline = try await StandardOutput.silenced { try await FlowTransformerPipeline(from: bundle) }
        } catch {
            throw .loadFailed(String(describing: error))
        }
        self.model = model
        self.bundle = bundle
        self.pipeline = pipeline
        self.size = pipeline.defaultImageSize
        // A single-shape export edits when it has an img2img transformer beside it; a
        // multi-shape export's folder names its own editing function.
        self.supportsEditing = model.supportsEditing && pipeline.supportsImageToImage
            && pipeline.img2imgRoutes[.full] != nil
        self.loraSlot = try LoRASlotLayout.inBundle(bundle)
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
    ///   - steps: Denoising steps, within ``GenerationModel/stepRange``; the
    ///     export's own default (FLUX 4, SANA 2) when `nil`.
    ///   - references: Pictures to draw from — a face, a product, a style —
    ///     up to ``maximumReferences``; FLUX.2 Klein 4B only. Each is cropped to
    ///     the centre at this export's shape.
    ///   - person: Someone a LoRA has learned, drawn through the export's
    ///     ``loraSlot`` — put their ``Person/trigger`` in the prompt. With
    ///     references only when the slot ``LoRASlotLayout/coversEditing``.
    ///   - progress: Called after each denoising step with (step, steps).
    /// - Returns: The pictures, in seed order, at the export's ``size``.
    /// - Throws: ``ImageGenerationError``; `.cancelled` when the task is;
    ///   `.personUnavailable` for a person on a plain export or with references.
    public func generate(_ prompt: String, seed: UInt32? = nil, count: Int = 1, allowText: Bool = false,
                         steps: Int? = nil, references: [CGImage] = [], person: Person? = nil,
                         progress: (@Sendable (Int, Int) -> Void)? = nil) async throws(ImageGenerationError) -> [GeneratedImage] {
        let text = try PromptText.validated(prompt, maximum: model.maximumPromptLength)
        guard (1...Self.maximumCount).contains(count) else { throw .invalidCount(count) }
        let stepCount = try resolvedSteps(steps)
        let extra = try checkedReferences(references, besides: 0)
        let slotInputs = try personInputs(person, editing: !extra.isEmpty)
        let sent = PromptText.composed(text, allowText: allowText)
        var pictures: [GeneratedImage] = []
        for picture in SeedPlan.seeds(start: seed, count: count) {
            var config = configuration(prompt: sent, seed: picture, startingImage: nil, strength: 1,
                                       steps: stepCount, references: extra)
            config.transformerInputs = slotInputs
            let (image, seconds) = try await run(config, progress: progress)
            pictures.append(GeneratedImage(image: image, seed: picture, model: model, prompt: text,
                                           promptSent: sent, edited: !extra.isEmpty, seconds: seconds))
        }
        return pictures
    }

    /// Changes a picture as `instruction` says — FLUX.2 Klein 4B or FLUX.3 Klein.
    ///
    /// FLUX.3 takes the instruction as written: a short request ("make the mug
    /// blue") or the full instruction or box record its prompt upsampler would
    /// write — measured, a short "remove the notebook" left the notebook, the
    /// written instruction removed it. Its `strength` is always 1.
    ///
    /// The source is trimmed to this export's shape around its centre first (the
    /// model works at a fixed size and would otherwise stretch it); load the export
    /// whose shape is nearest the source's (``ImageAspect/nearest(width:height:among:)``)
    /// and the trim is a sliver — ``trim(of:)`` says how much.
    ///
    /// - Parameters:
    ///   - image: The picture to change.
    ///   - instruction: What to change, e.g. "make it night".
    ///   - seed: Random when `nil`.
    ///   - strength: How far the result may move from the source, 0…1. 1 (the
    ///     default) redraws from pure noise with the source only as a reference;
    ///     below 1 the redraw starts from the source itself blended with noise, so
    ///     lower keeps more of it — layout, faces, fine detail.
    ///   - allowText: As for ``generate(_:seed:count:allowText:steps:references:progress:)``.
    ///   - steps: As for ``generate(_:seed:count:allowText:steps:references:progress:)``.
    ///   - references: Further pictures to draw from, after `image`; together
    ///     at most ``maximumReferences``.
    ///   - person: Someone a LoRA has learned, drawn into the edit — the export's
    ///     slot must ``LoRASlotLayout/coversEditing``.
    ///   - progress: As for ``generate(_:seed:count:allowText:steps:references:progress:)``.
    /// - Throws: ``ImageGenerationError``; `.editingUnavailable` for SANA or
    ///   when the editing parts are not installed.
    public func edit(_ image: CGImage, _ instruction: String, seed: UInt32? = nil, strength: Float = 1,
                     allowText: Bool = false, steps: Int? = nil, references: [CGImage] = [], person: Person? = nil,
                     progress: (@Sendable (Int, Int) -> Void)? = nil) async throws(ImageGenerationError) -> GeneratedImage {
        try requireEditing()
        let extra = try checkedReferences(references, besides: 1)
        let slotInputs = try personInputs(person, editing: true)
        guard strength > 0, strength <= 1 else { throw .invalidPrompt("Strength is more than 0 and at most 1") }
        // FLUX.3 edits from noise with the picture as a reference, as it was trained to;
        // starting from the picture itself is FLUX.2's.
        guard !model.isFlux3 || strength == 1 else {
            throw .invalidPrompt("FLUX.3 redraws from noise with the picture as a reference; strength is FLUX.2's")
        }
        let text = try PromptText.validated(instruction, maximum: model.maximumPromptLength)
        let stepCount = try resolvedSteps(steps)
        let sent = PromptText.composed(text, allowText: allowText)
        let picture = SeedPlan.seeds(start: seed, count: 1)[0]
        var config = configuration(prompt: sent, seed: picture,
                                   startingImage: AspectMath.centred(image, width: size.width, height: size.height),
                                   strength: strength, steps: stepCount, references: extra)
        config.transformerInputs = slotInputs
        let (result, seconds) = try await run(config, progress: progress)
        return GeneratedImage(image: result, seed: picture, model: model, prompt: text,
                              promptSent: sent, edited: true, seconds: seconds)
    }

    /// How much of `image` an edit at this export's shape trims away around the
    /// centre, 0…1 — 0 when the shapes match.
    public func trim(of image: CGImage) -> Double {
        AspectMath.trimmed(width: image.width, height: image.height, targetWidth: size.width, targetHeight: size.height)
    }

    // MARK: - Plumbing

    /// Throws unless this model and export can take a picture in.
    private func requireEditing() throws(ImageGenerationError) {
        guard model.supportsEditing else {
            throw .editingUnavailable("\(model.displayName) cannot edit pictures; FLUX.2 Klein 4B and FLUX.3 Klein can")
        }
        guard supportsEditing else {
            throw .editingUnavailable("This \(model.displayName) export has no editing parts for \(size.width)×\(size.height) "
                                      + "(an img2img transformer function and a VAEEncoder)")
        }
    }

    /// A person's matrices as the slot's inputs; none without a person.
    private func personInputs(_ person: Person?, editing: Bool) throws(ImageGenerationError) -> [String: NDArray] {
        guard let person else { return [:] }
        guard let loraSlot else {
            throw .personUnavailable("this export has no LoRA slot (\(LoRASlotLayout.fileName)), so it cannot draw \(person.name)")
        }
        // A slot export from before multi-shape carries the slot in text to image
        // only; its editing transformer would silently ignore the person.
        guard !editing || loraSlot.coversEditing else {
            throw .personUnavailable("this export's editing transformer has no LoRA slot, so \(person.name) cannot go into an edit")
        }
        return try SlotInputs.inputs(for: person, layout: loraSlot)
    }

    /// The references, checked against the limit and cropped square.
    private func checkedReferences(_ references: [CGImage], besides others: Int) throws(ImageGenerationError) -> [CGImage] {
        guard !references.isEmpty else { return [] }
        try requireEditing()
        guard references.count + others <= Self.maximumReferences else {
            throw .tooManyReferences(references.count + others)
        }
        return references.map { AspectMath.centred($0, width: size.width, height: size.height) }
    }

    /// The step count to run: the caller's, checked, or the export's default.
    private func resolvedSteps(_ steps: Int?) throws(ImageGenerationError) -> Int {
        guard let steps else { return defaults.steps }
        guard model.stepRange.contains(steps) else { throw .invalidSteps(steps, model) }
        return steps
    }

    private func configuration(prompt: String, seed: UInt32, startingImage: CGImage?,
                               strength: Float, steps: Int, references: [CGImage] = []) -> PipelineConfiguration {
        PipelineConfiguration(
            prompt: prompt, seed: seed,
            stepCount: steps, guidanceScale: defaults.guidance,
            schedulerType: .discreteFlow,
            startingImage: startingImage, strength: strength,
            encoderScaleFactor: defaults.encoderScale,
            decoderScaleFactor: defaults.decoderScale,
            decoderShiftFactor: defaults.decoderShift,
            lazyModelLoading: defaults.lazy,
            additionalReferences: references)
    }

    private func run(_ config: PipelineConfiguration,
                     progress: (@Sendable (Int, Int) -> Void)?) async throws(ImageGenerationError) -> (CGImage, Double) {
        let clock = ContinuousClock()
        let started = clock.now
        let images: [CGImage]
        do {
            // Parts load here too when they load one at a time.
            images = try await StandardOutput.silenced {
                try await pipeline.generateImages(configuration: config) { step in
                    progress?(step.step, step.totalSteps)
                    return !Task.isCancelled
                }.images
            }
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
