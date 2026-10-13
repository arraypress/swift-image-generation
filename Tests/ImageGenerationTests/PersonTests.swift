//
//  PersonTests.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//
//  People need no model: importing a trainer's LoRA, the person file, and the
//  slot inputs a run hands the transformer. That a person comes out of the
//  slot export is measured through `imagine` (the owl in its README).
//

import CoreAI
import CoreAIDiffusionPipeline
import Foundation
import Testing
@testable import ImageGeneration

@Suite("People")
struct PersonTests {

    /// Two layers, slot rank 4.
    static let layout = LoRASlotLayout(rank: 4, layers: [
        .init(name: "transformer_blocks.0.attn.to_q", inFeatures: 3, outFeatures: 2),
        .init(name: "single_transformer_blocks.0.attn.to_out", inFeatures: 2, outFeatures: 3),
    ])

    static func f32(_ values: [Float]) -> Data { values.withUnsafeBytes { Data($0) } }

    /// A rank-2 LoRA in diffusers' naming, alpha 4 in the metadata (scale 2).
    static func lora(prefix: String = "transformer.", suffix: String = ".weight", extra: [String: (String, [Int], Data)] = [:],
                     alpha: String? = "4") -> Data {
        var tensors: [(name: String, dtype: String, shape: [Int], bytes: Data)] = [
            ("\(prefix)transformer_blocks.0.attn.to_q.lora_A\(suffix)", "F32", [2, 3], f32([1, 2, 3, 4, 5, 6])),
            ("\(prefix)transformer_blocks.0.attn.to_q.lora_B\(suffix)", "F32", [2, 2], f32([0.5, 1, 1.5, 2])),
        ]
        for (name, (dtype, shape, bytes)) in extra { tensors.append((name, dtype, shape, bytes)) }
        return SafeTensors.write(metadata: alpha.map { ["alpha": $0] } ?? [:], tensors: tensors)
    }

    static func floats(_ half: Data) -> [Float] { HalfFloat.floats(fromHalf: half) }

    @Test("A diffusers LoRA imports: prefixes stripped, alpha/rank folded into B, F16")
    func importsDiffusers() throws {
        let person = try Person.importing(lora: Self.lora(), name: "owl", trigger: " zxq plush owl ", layout: Self.layout)
        #expect(person.rank == 2 && person.trigger == "zxq plush owl" && person.layout == Self.layout.identifier)
        #expect(person.layers.count == 1 && person.layers[0].name == "transformer_blocks.0.attn.to_q")
        #expect(Self.floats(person.layers[0].a) == [1, 2, 3, 4, 5, 6])
        #expect(Self.floats(person.layers[0].b) == [1, 2, 3, 4])
        #expect(person.baseModel == Person.defaultBaseModel)
    }

    @Test("Bare `<layer>.lora_A` names import, and no alpha means scale 1")
    func importsBare() throws {
        let person = try Person.importing(lora: Self.lora(prefix: "", suffix: "", alpha: nil), name: "owl",
                                          trigger: "zxq", layout: Self.layout)
        #expect(Self.floats(person.layers[0].b) == [0.5, 1, 1.5, 2])
    }

    @Test("A person file round-trips exactly")
    func roundTrip() throws {
        let person = try Person.importing(lora: Self.lora(), name: "owl", trigger: "zxq", layout: Self.layout)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("person-\(UUID()).safetensors")
        defer { try? FileManager.default.removeItem(at: url) }
        try person.write(to: url)
        #expect(try Person(contentsOf: url) == person)
    }

    @Test("A LoRA file is not a person file until imported")
    func loraIsNotAPerson() {
        #expect(throws: ImageGenerationError.self) { try PersonFile.decode(Self.lora()) }
    }

    @Test("Layers the slot does not have are refused by name")
    func refusesForeignLayers() {
        let extra = ["transformer.norm_out.linear.lora_A.weight": ("F32", [2, 3], Self.f32([0, 0, 0, 0, 0, 0])),
                     "transformer.norm_out.linear.lora_B.weight": ("F32", [2, 2], Self.f32([0, 0, 0, 0]))]
        #expect {
            try Person.importing(lora: Self.lora(extra: extra), name: "owl", trigger: "zxq", layout: Self.layout)
        } throws: { error in
            "\(error)".contains("norm_out.linear")
        }
    }

    @Test("A rank above the slot's, a wrong shape and a kohya file are refused")
    func refusesMisfits() {
        let wide = LoRASlotLayout(rank: 1, layers: Self.layout.layers)
        #expect(throws: ImageGenerationError.self) {
            try Person.importing(lora: Self.lora(), name: "owl", trigger: "zxq", layout: wide)
        }
        let other = LoRASlotLayout(rank: 4, layers: [.init(name: "transformer_blocks.0.attn.to_q", inFeatures: 5, outFeatures: 2)])
        #expect(throws: ImageGenerationError.self) {
            try Person.importing(lora: Self.lora(), name: "owl", trigger: "zxq", layout: other)
        }
        let kohya = SafeTensors.write(metadata: [:], tensors: [("lora_unet_x.lora_down.weight", "F32", [1], Self.f32([0]))])
        #expect(throws: ImageGenerationError.self) {
            try Person.importing(lora: kohya, name: "owl", trigger: "zxq", layout: Self.layout)
        }
    }

    @Test("Slot inputs pad to the slot's rank with zeros and skip untrained layers")
    func slotInputsPad() throws {
        let person = try Person.importing(lora: Self.lora(), name: "owl", trigger: "zxq", layout: Self.layout)
        let inputs = try SlotInputs.inputs(for: person, layout: Self.layout)
        #expect(Set(inputs.keys) == ["lora_a_0", "lora_b_0"])
        #expect(inputs["lora_a_0"]?.shape == [4, 3])
        #expect(inputs["lora_b_0"]?.shape == [2, 4])
        func values(_ array: NDArray) -> [Float] {
            var out: [Float] = []
            array.view(as: Float16.self).withUnsafePointer { pointer, shape, strides in
                for row in 0..<shape[0] {
                    for column in 0..<shape[1] { out.append(Float(pointer[row * strides[0] + column * strides[1]])) }
                }
            }
            return out
        }
        #expect(values(inputs["lora_a_0"]!) == [1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0])
        #expect(values(inputs["lora_b_0"]!) == [1, 2, 0, 0, 3, 4, 0, 0])
    }

    @Test("A person made for another slot is refused")
    func otherSlot() throws {
        let person = try Person.importing(lora: Self.lora(), name: "owl", trigger: "zxq", layout: Self.layout)
        let other = LoRASlotLayout(rank: 4, layers: [Self.layout.layers[0]])
        #expect(throws: ImageGenerationError.self) { try SlotInputs.inputs(for: person, layout: other) }
    }

    @Test("The layout identifier ignores the rank, not the layers")
    func identifier() {
        #expect(LoRASlotLayout(rank: 8, layers: Self.layout.layers).identifier == Self.layout.identifier)
        #expect(LoRASlotLayout(rank: 4, layers: [Self.layout.layers[1]]).identifier != Self.layout.identifier)
    }

    @Test("slot.json decodes with its in/out keys")
    func slotJSON() throws {
        let json = #"{"rank": 16, "layers": [{"name": "transformer_blocks.0.attn.to_q", "in": 3072, "out": 3072}]}"#
        let layout = try JSONDecoder().decode(LoRASlotLayout.self, from: Data(json.utf8))
        #expect(layout.rank == 16 && layout.layers[0].inFeatures == 3072)
    }

    @Test("Names are safe as folder names")
    func names() {
        #expect(Person.isValidName("owl") && Person.isValidName("dave_2-b"))
        #expect(!Person.isValidName("") && !Person.isValidName("../x") && !Person.isValidName("-x") && !Person.isValidName("a b"))
    }

    @Test("A recipe records a person by name, and refuses a bad one")
    func recipePerson() throws {
        var recipe = ImageRecipe(prompt: .init(text: "a photo"))
        recipe = try recipe.setting("person", to: "owl")
        #expect(recipe.settings.person == "owl")
        #expect(throws: ImageGenerationError.self) { try recipe.setting("person", to: "../etc") }
    }
}
