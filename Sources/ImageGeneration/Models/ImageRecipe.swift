//
//  ImageRecipe.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  A picture as data: the prompt in named parts, the settings, the pictures
//  it starts from and what made it. The same recipe and seed make the same
//  picture, byte for byte, so a recipe is something to keep, diff and hand
//  on. The JSON keys are snake_case and the format is versioned
//  (`"imagine": 1`); reading and writing go through ``ImageRecipe/decode(_:)``
//  and ``ImageRecipe/encoded()``, which refuse keys they do not know.
//

import Foundation

/// A picture as data — a prompt, settings, inputs and provenance.
public struct ImageRecipe: Codable, Sendable, Equatable {

    /// The format version: `"imagine": 1`.
    public var imagine: Int

    /// What to draw.
    public var prompt: Prompt

    /// How to draw it.
    public var settings: Settings

    /// Pictures it starts from or draws on; `nil` for none.
    public var inputs: Inputs?

    /// What wrote the recipe; informational, never read back as a setting.
    public var provenance: Provenance?

    public init(prompt: Prompt, settings: Settings = Settings(), inputs: Inputs? = nil,
                provenance: Provenance? = nil) {
        self.imagine = ImageRecipe.formatVersion
        self.prompt = prompt
        self.settings = settings
        self.inputs = inputs
        self.provenance = provenance
    }

    /// The prompt, either as one `text` or in named parts — composed in the
    /// order text, subject, details, setting, lighting, camera, style, extra.
    public struct Prompt: Codable, Sendable, Equatable {
        /// A whole prompt, as typed.
        public var text: String?
        /// The thing in the picture: "a red bicycle".
        public var subject: String?
        /// About the subject: "rusty chain", "wicker basket".
        public var details: [String]?
        /// Where: "against a blue door".
        public var setting: String?
        /// "late afternoon sun".
        public var lighting: String?
        /// "35mm, shallow depth of field".
        public var camera: String?
        /// "film photograph".
        public var style: String?
        /// Anything else, last.
        public var extra: [String]?
        /// Whether the model is told to draw no text; `nil` for the model's
        /// default (FLUX.2 Klein 9B draws text, the others are told not to).
        public var avoidText: Bool?

        public init(text: String? = nil, subject: String? = nil, details: [String]? = nil, setting: String? = nil,
                    lighting: String? = nil, camera: String? = nil, style: String? = nil, extra: [String]? = nil,
                    avoidText: Bool? = nil) {
            self.text = text
            self.subject = subject
            self.details = details
            self.setting = setting
            self.lighting = lighting
            self.camera = camera
            self.style = style
            self.extra = extra
            self.avoidText = avoidText
        }

        enum CodingKeys: String, CodingKey, CaseIterable {
            case text, subject, details, setting, lighting, camera, style, extra
            case avoidText = "avoid_text"
        }
    }

    /// The model and its knobs. Every field is optional: `nil` is the model's
    /// default, and a `nil` seed is a random one.
    public struct Settings: Codable, Sendable, Equatable {
        /// A ``GenerationModel`` raw value: `flux2-klein-4b`, `sana-sprint-1.6b`, `flux2-klein-9b`.
        public var model: String?
        /// An ``ImageAspect`` raw value: `1:1`, `16:9`, `9:16`, `4:5`.
        public var aspect: String?
        /// The first seed; picture n uses seed + n.
        public var seed: UInt32?
        /// Denoising steps.
        public var steps: Int?
        /// How many pictures.
        public var count: Int?
        /// Enlarge each picture this many times afterwards.
        public var upscale: Int?
        /// With an edit: how far from the source, 0–1.
        public var strength: Double?
        /// Redraw small faces afterwards (`true`), or not (`false`); `nil`
        /// leaves it to the tool's default.
        public var fixFaces: Bool?
        /// A trained person (``Person``) by name — the name, never the weights,
        /// so the recipe stays small and replays only where that person is installed.
        public var person: String?

        public init(model: String? = nil, aspect: String? = nil, seed: UInt32? = nil, steps: Int? = nil,
                    count: Int? = nil, upscale: Int? = nil, strength: Double? = nil, fixFaces: Bool? = nil,
                    person: String? = nil) {
            self.model = model
            self.aspect = aspect
            self.seed = seed
            self.steps = steps
            self.count = count
            self.upscale = upscale
            self.strength = strength
            self.fixFaces = fixFaces
            self.person = person
        }

        enum CodingKeys: String, CodingKey, CaseIterable {
            case model, aspect, seed, steps, count, upscale, strength
            case fixFaces = "fix_faces"
            case person
        }
    }

    /// Pictures in. Paths are relative to the recipe file unless absolute.
    public struct Inputs: Codable, Sendable, Equatable {
        /// The picture to change.
        public var edit: String?
        /// Change only these things, keeping the original's detail.
        public var only: [String]?
        /// Change only these things, taking the edit's own detail.
        public var replace: [String]?
        /// Other pictures to draw from.
        public var references: [String]?
        /// Ignore `only` / `replace` matches scoring below this, 0–1.
        public var maskMinScore: Double?

        public init(edit: String? = nil, only: [String]? = nil, replace: [String]? = nil,
                    references: [String]? = nil, maskMinScore: Double? = nil) {
            self.edit = edit
            self.only = only
            self.replace = replace
            self.references = references
            self.maskMinScore = maskMinScore
        }

        enum CodingKeys: String, CodingKey, CaseIterable {
            case edit, only, replace, references
            case maskMinScore = "mask_min_score"
        }
    }

    /// What wrote the recipe.
    public struct Provenance: Codable, Sendable, Equatable {
        /// The tool and its version: `imagine 0.6.0`.
        public var tool: String?
        /// The model export's pinned revision (a Hugging Face commit).
        public var modelRevision: String?
        /// The built-in style the prompt was written from (``ImageStyle``).
        /// The prompt itself holds the scene in full, so a replay never
        /// needs the style; this says where it came from.
        public var style: String?
        /// The style's scene, one-based.
        public var scene: Int?
        /// Every slot's value when the prompt was written — the caller's or
        /// the default — keyed by slot name: `{"room": "kitchen"}`.
        public var vars: [String: String]?

        public init(tool: String? = nil, modelRevision: String? = nil, style: String? = nil, scene: Int? = nil,
                    vars: [String: String]? = nil) {
            self.tool = tool
            self.modelRevision = modelRevision
            self.style = style
            self.scene = scene
            self.vars = vars
        }

        enum CodingKeys: String, CodingKey, CaseIterable {
            case tool
            case modelRevision = "model_revision"
            case style, scene, vars
        }
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case imagine, prompt, settings, inputs, provenance
    }

    /// `settings` may be left out: every one of its fields has a default.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imagine = try container.decode(Int.self, forKey: .imagine)
        prompt = try container.decode(Prompt.self, forKey: .prompt)
        settings = try container.decodeIfPresent(Settings.self, forKey: .settings) ?? Settings()
        inputs = try container.decodeIfPresent(Inputs.self, forKey: .inputs)
        provenance = try container.decodeIfPresent(Provenance.self, forKey: .provenance)
    }
}
