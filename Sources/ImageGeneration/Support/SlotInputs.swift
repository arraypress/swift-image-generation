//
//  SlotInputs.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  A person's matrices as the slot transformer's inputs: `lora_a_<i>` and
//  `lora_b_<i>` in the layout's order, each padded with zeros to the slot's
//  rank. Layers the person has no matrices for are left out, and the pipeline
//  fills them with zeros — the plain model in those layers.
//

import CoreAI
import CoreAIDiffusionPipeline
import Foundation

enum SlotInputs {

    /// The inputs for `person` on a transformer with `layout`.
    static func inputs(for person: Person, layout: LoRASlotLayout) throws(ImageGenerationError) -> [String: NDArray] {
        guard person.layout == layout.identifier else {
            throw .personUnavailable("\(person.name) was made for another LoRA slot (\(person.layout.prefix(12))…); "
                                     + "this export's is \(layout.identifier.prefix(12))…")
        }
        guard person.rank <= layout.rank else {
            throw .personUnavailable("\(person.name) is rank \(person.rank); this export's slot takes \(layout.rank)")
        }
        let trained = Dictionary(uniqueKeysWithValues: person.layers.map { ($0.name, $0) })
        var inputs: [String: NDArray] = [:]
        for (index, layer) in layout.layers.enumerated() {
            guard let matrices = trained[layer.name] else { continue }
            guard matrices.a.count == person.rank * layer.inFeatures * 2,
                  matrices.b.count == layer.outFeatures * person.rank * 2 else {
                throw .invalidPerson("\(person.name)'s \(layer.name) is the wrong size for the slot")
            }
            inputs[LoRASlot.aName(index)] = array(rows: layout.rank, columns: layer.inFeatures) { row, column in
                row < person.rank ? halfBits(matrices.a, at: row * layer.inFeatures + column) : 0
            }
            inputs[LoRASlot.bName(index)] = array(rows: layer.outFeatures, columns: layout.rank) { row, column in
                column < person.rank ? halfBits(matrices.b, at: row * person.rank + column) : 0
            }
        }
        return inputs
    }

    /// One little-endian half float's bits from a buffer.
    private static func halfBits(_ data: Data, at index: Int) -> UInt16 {
        let offset = data.startIndex + 2 * index
        return UInt16(data[offset]) | (UInt16(data[offset + 1]) << 8)
    }

    /// A `[rows, columns]` F16 array, filled through the array's own strides.
    private static func array(rows: Int, columns: Int, value: (Int, Int) -> UInt16) -> NDArray {
        var array = NDArray(shape: [rows, columns], scalarType: .float16)
        array.mutableRawView().withUnsafeMutableBytes { pointer, _, strides in
            let destination = pointer.assumingMemoryBound(to: UInt16.self)
            for row in 0..<rows {
                for column in 0..<columns {
                    destination[row * strides[0] + column * strides[1]] = value(row, column)
                }
            }
        }
        return array
    }
}
