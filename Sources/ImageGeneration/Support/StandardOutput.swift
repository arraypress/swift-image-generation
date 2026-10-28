//
//  StandardOutput.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation
import Synchronization

/// Core AI prints its compiler's warnings to standard output while it loads a
/// model — six lines of MLIR for every load of FLUX.3 at 4 bits — where a
/// tool's JSON goes. While a model loads and runs, standard output points at
/// /dev/null. Overlapping uses share one diversion, restored when the last one
/// ends, so stdout comes back whichever order they finish in.
enum StandardOutput {

    /// How many uses are under way, and the real stdout while any is.
    private static let state = Mutex<(depth: Int, saved: Int32)>((0, -1))

    /// Runs `body` with standard output silenced.
    static func silenced<T>(_ body: () async throws -> T) async rethrows -> T {
        divert()
        defer { restore() }
        return try await body()
    }

    /// Points standard output at /dev/null, unless a use under way already has.
    static func divert() {
        state.withLock { state in
            if state.depth == 0 {
                fflush(stdout)
                state.saved = dup(STDOUT_FILENO)
                let null = open("/dev/null", O_WRONLY)
                dup2(null, STDOUT_FILENO)
                close(null)
            }
            state.depth += 1
        }
    }

    /// Ends one use; the last one brings standard output back.
    static func restore() {
        state.withLock { state in
            state.depth -= 1
            guard state.depth == 0 else { return }
            fflush(stdout)
            dup2(state.saved, STDOUT_FILENO)
            close(state.saved)
            state.saved = -1
        }
    }
}
