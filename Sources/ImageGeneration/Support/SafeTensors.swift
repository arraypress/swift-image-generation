//
//  SafeTensors.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The safetensors container, which every LoRA trainer writes: an 8-byte
//  little-endian header length, a JSON header naming each tensor's dtype,
//  shape and byte range, then the bytes. Only what LoRAs use is read —
//  F32, F16 and BF16.
//

import Foundation

enum SafeTensors {

    /// One tensor's description and bytes.
    struct Tensor {
        let dtype: String
        let shape: [Int]
        let bytes: Data
    }

    /// A file's string metadata and its tensors by name.
    static func read(_ data: Data) throws(ImageGenerationError) -> (metadata: [String: String], tensors: [String: Tensor]) {
        guard data.count >= 8 else { throw .invalidPerson("not a safetensors file: too short") }
        let length = data.prefix(8).enumerated().reduce(0) { $0 | (Int($1.element) << (8 * $1.offset)) }
        guard length > 0, 8 + length <= data.count else { throw .invalidPerson("not a safetensors file: bad header length") }
        let start = data.startIndex + 8
        guard let header = try? JSONSerialization.jsonObject(with: data[start..<start + length]) as? [String: Any] else {
            throw .invalidPerson("not a safetensors file: the header is not JSON")
        }
        let body = start + length
        var metadata: [String: String] = [:]
        var tensors: [String: Tensor] = [:]
        for (name, value) in header {
            guard let entry = value as? [String: Any] else { continue }
            if name == "__metadata__" {
                for (key, item) in entry { metadata[key] = item as? String ?? "\(item)" }
                continue
            }
            guard let dtype = entry["dtype"] as? String, let shape = entry["shape"] as? [Int],
                  let offsets = entry["data_offsets"] as? [Int], offsets.count == 2,
                  offsets[0] >= 0, offsets[0] <= offsets[1], body + offsets[1] <= data.endIndex else {
                throw .invalidPerson("not a safetensors file: \(name) has a bad description")
            }
            tensors[name] = Tensor(dtype: dtype, shape: shape, bytes: data[(body + offsets[0])..<(body + offsets[1])])
        }
        return (metadata, tensors)
    }

    /// Only a file's metadata, read from its header without the tensors.
    static func metadata(of url: URL) throws(ImageGenerationError) -> [String: String] {
        guard let handle = try? FileHandle(forReadingFrom: url) else { throw .invalidPerson("could not read \(url.path)") }
        defer { try? handle.close() }
        guard let prefix = try? handle.read(upToCount: 8), prefix.count == 8 else {
            throw .invalidPerson("not a safetensors file: too short")
        }
        let length = prefix.enumerated().reduce(0) { $0 | (Int($1.element) << (8 * $1.offset)) }
        guard length > 0, length < 100_000_000, let header = try? handle.read(upToCount: length), header.count == length,
              let json = try? JSONSerialization.jsonObject(with: header) as? [String: Any] else {
            throw .invalidPerson("not a safetensors file: bad header")
        }
        let entry = json["__metadata__"] as? [String: Any] ?? [:]
        return entry.mapValues { $0 as? String ?? "\($0)" }
    }

    /// A safetensors file of the given tensors, in the given order.
    static func write(metadata: [String: String], tensors: [(name: String, dtype: String, shape: [Int], bytes: Data)]) -> Data {
        var header: [String: Any] = ["__metadata__": metadata]
        var offset = 0
        for tensor in tensors {
            header[tensor.name] = ["dtype": tensor.dtype, "shape": tensor.shape, "data_offsets": [offset, offset + tensor.bytes.count]]
            offset += tensor.bytes.count
        }
        var json = (try? JSONSerialization.data(withJSONObject: header, options: [.sortedKeys])) ?? Data("{}".utf8)
        // The format asks for the data to start 8-byte aligned; pad the header with spaces.
        while (8 + json.count) % 8 != 0 { json.append(0x20) }
        var out = Data()
        var length = UInt64(json.count).littleEndian
        withUnsafeBytes(of: &length) { out.append(contentsOf: $0) }
        out.append(json)
        for tensor in tensors { out.append(tensor.bytes) }
        return out
    }

    /// A tensor's values as half-float bits, whatever its stored precision.
    static func halfFloats(_ tensor: Tensor, name: String) throws(ImageGenerationError) -> Data {
        let count = tensor.shape.reduce(1, *)
        switch tensor.dtype {
        case "F16":
            guard tensor.bytes.count == count * 2 else { throw .invalidPerson("\(name) is the wrong size for its shape") }
            return Data(tensor.bytes)
        case "F32":
            guard tensor.bytes.count == count * 4 else { throw .invalidPerson("\(name) is the wrong size for its shape") }
            return HalfFloat.fromFloats(HalfFloat.floats(fromF32: tensor.bytes))
        case "BF16":
            guard tensor.bytes.count == count * 2 else { throw .invalidPerson("\(name) is the wrong size for its shape") }
            return HalfFloat.fromFloats(HalfFloat.floats(fromBF16: tensor.bytes))
        default:
            throw .invalidPerson("\(name) is \(tensor.dtype); a LoRA here is F32, F16 or BF16")
        }
    }

    /// A tensor's values as floats (for scalars such as a layer's alpha).
    static func floats(_ tensor: Tensor) -> [Float] {
        switch tensor.dtype {
        case "F32": HalfFloat.floats(fromF32: tensor.bytes)
        case "F16": HalfFloat.floats(fromHalf: tensor.bytes)
        case "BF16": HalfFloat.floats(fromBF16: tensor.bytes)
        default: []
        }
    }
}
