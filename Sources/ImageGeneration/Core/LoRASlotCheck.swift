//
//  LoRASlotCheck.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Proof that a transformer is the LoRA-slot export its `slot.json` says,
//  before anything is replaced by it: the asset loads on this Mac and its
//  function takes exactly the slot's inputs, in the slot's shapes. Loading is
//  the compile a first run would pay anyway, and Core AI keys that cache by
//  the asset's content, so the asset can move afterwards without paying again.
//

import CoreAI
import Foundation

public enum LoRASlotCheck {

    /// Loads `transformer` and checks its inputs against `layout`.
    ///
    /// - Throws: ``ImageGenerationError/loadFailed(_:)`` when the asset does
    ///   not load or does not take the slot's inputs.
    public static func verify(transformer: URL, layout: LoRASlotLayout) async throws(ImageGenerationError) {
        let function: InferenceFunction
        do {
            let model = try await AIModel(contentsOf: transformer, options: SpecializationOptions(preferredComputeUnitKind: .gpu))
            guard let loaded = try model.loadFunction(named: "main") else {
                throw ImageGenerationError.loadFailed("\(transformer.lastPathComponent) has no main function")
            }
            function = loaded
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            throw .loadFailed("\(transformer.lastPathComponent): \(error.localizedDescription)")
        }
        let names = function.descriptor.inputNames
        let slotNames = names.filter { $0.hasPrefix("lora_") }
        guard slotNames.count == 2 * layout.layers.count else {
            throw .loadFailed("\(transformer.lastPathComponent) takes \(slotNames.count) LoRA inputs; its slot.json lists "
                              + "\(layout.layers.count) layers (\(2 * layout.layers.count) inputs)")
        }
        for (index, layer) in layout.layers.enumerated() {
            for (name, shape) in [("lora_a_\(index)", [layout.rank, layer.inFeatures]),
                                  ("lora_b_\(index)", [layer.outFeatures, layout.rank])] {
                guard case .ndArray(let descriptor) = function.descriptor.inputDescriptor(of: name),
                      descriptor.shape == shape else {
                    throw .loadFailed("\(transformer.lastPathComponent)'s \(name) is not \(shape) as \(layer.name) needs")
                }
            }
        }
    }
}
