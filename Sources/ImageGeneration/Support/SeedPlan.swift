//
//  SeedPlan.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// The seeds for a run: the one given (or a random one) and the next ones up,
/// so a run of four from seed 7 is 7, 8, 9, 10 — any picture in it can be
/// made again on its own from its printed seed.
enum SeedPlan {

    static func seeds(start: UInt32?, count: Int,
                      random: () -> UInt32 = { UInt32.random(in: 0...UInt32.max) }) -> [UInt32] {
        let first = start ?? random()
        return (0..<max(0, count)).map { first &+ UInt32($0) }
    }
}
