//
//  GarmentText.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The words that dress someone: what a garment picture is (SAM 3 scores
//  over one word per kind), what to mask on the person for it, and the
//  instruction FLUX gets. The recipe is the one measured on generated
//  fashion photos (2026-10-14): one garment per step, the person's own
//  garment replaced (so the new one's detail comes through), the arm added
//  for a sleeved garment — without it a jacket came out short-sleeved,
//  because a garment cannot leave its mask — and an instruction that says
//  what to keep. A plain unmasked edit changed the person (a melted face);
//  masked, every pixel outside the mask stayed. The instruction is for a
//  side-by-side edit (Support/SideBySide.swift): the person on the left,
//  the garment on the right.
//

import Foundation

enum GarmentText {

    /// The word SAM 3 is asked for on the garment's own picture, per kind.
    static let classWords: [GarmentKind: String] = [
        .top: "top", .outerwear: "jacket", .dress: "dress", .skirt: "skirt",
        .trousers: "trousers", .shorts: "shorts", .shoes: "shoes", .hat: "hat",
    ]

    /// Which kind wins a near-tie (scores within ``tieMargin``): the more
    /// particular one. A dress on a mannequin scores high as "top" too, and a
    /// jacket as "top" (0.79) — never the other way round by much.
    static let precedence: [GarmentKind] = [.dress, .outerwear, .skirt, .shorts, .trousers, .shoes, .hat, .top]

    /// Scores closer than this are a tie. Measured: the widest wrong-kind
    /// score below a right one was a striped top's "dress" (0.92 against
    /// 0.98 "top"); the closest right-over-wrong was a jacket's "jacket"
    /// 0.97 over "shirt" 0.96 — which is why "shirt" is not a class word.
    static let tieMargin = 0.03

    /// The kind a garment picture is, from each kind's best score; `nil` when
    /// nothing reaches `minimum`.
    static func classify(_ scores: [GarmentKind: Double], minimum: Double) -> GarmentKind? {
        let passing = scores.filter { $0.value >= minimum }
        guard let best = passing.values.max() else { return nil }
        let near = passing.filter { $0.value >= best - tieMargin }.map(\.key)
        return precedence.first { near.contains($0) }
    }

    /// The kind a word names: `tshirt`, `blazer`, `jeans`, `sneakers`… —
    /// `nil` for a word that is not a garment this knows.
    static func kind(named word: String) -> GarmentKind? {
        let key = RegionWords.key(word)
        if let kind = GarmentKind(rawValue: key) { return kind }
        let words: [GarmentKind: [String]] = [
            .top: ["tshirt", "t-shirt", "tee", "shirt", "blouse", "sweater", "jumper", "hoodie", "sweatshirt",
                   "cardigan", "polo", "tank top", "vest"],
            .outerwear: ["jacket", "blazer", "coat", "parka", "suit jacket", "outer"],
            .dress: ["gown"],
            .trousers: ["pants", "jeans", "slacks", "chinos", "leggings"],
            .shoes: ["sneakers", "trainers", "boots", "heels", "sandals", "footwear"],
            .hat: ["cap", "beanie"],
        ]
        return words.first { $0.value.contains(key) }?.key
    }

    /// Whether a garment of this kind sits on the upper body, where sleeves
    /// decide how much of the arm it covers.
    static func upperBody(_ kind: GarmentKind) -> Bool { [.top, .outerwear, .dress].contains(kind) }

    /// Upper-body garments a person may be wearing now.
    static let upper = ["tshirt", "top", "shirt", "sweater", "blouse"]
    static let outer = ["blazer", "jacket", "coat"]
    static let lower = ["trousers", "jeans", "pants", "shorts", "skirt"]

    /// What to replace on the person for a garment of `kind`. `sleeved`: the
    /// garment's picture has sleeves (SAM 3's "sleeve" passed), so the arm is
    /// replaced too. At least one region must be found (``atLeastOne``).
    static func regions(for kind: GarmentKind, sleeved: Bool) -> [GarmentRegion] {
        let arm = GarmentRegion(words: ["arm", "arms"], required: false)
        var out: [GarmentRegion]
        switch kind {
        case .top: out = [.init(words: upper, required: false), .init(words: outer, required: false)]
        case .outerwear:
            // The neck too: a jacket's collar stands above a t-shirt's neckline,
            // and clipped at the t-shirt's mask it faded into the skin (measured).
            out = [.init(words: outer, required: false), .init(words: upper, required: false),
                   .init(words: ["neck"], required: false)]
        case .dress:
            out = [.init(words: ["dress"], required: false), .init(words: upper, required: false),
                   .init(words: outer, required: false), .init(words: lower, required: false)]
        case .skirt, .trousers, .shorts: out = [.init(words: lower, required: true)]
        case .shoes: out = [.init(words: ["shoes", "sneakers", "boots"], required: false),
                            .init(words: ["feet", "foot"], required: false), .init(words: ["socks"], required: false)]
        case .hat: out = [.init(words: ["hat", "cap"], required: false), .init(words: ["hair"], required: false)]
        }
        if upperBody(kind), sleeved { out.append(arm) }
        return out
    }

    /// The noun for the garment in an instruction.
    static func noun(_ kind: GarmentKind) -> String {
        switch kind {
        case .outerwear: "jacket"
        default: kind.rawValue
        }
    }

    /// Whether sleeves are long: the sleeves' lowest point reaches this far
    /// down the garment (0 at its top, 1 at its hem). Measured on two long-
    /// sleeved garments — a knit top and a jacket — at 1.0 both; a short
    /// sleeve ends about a third of the way down.
    static let longSleeveReach = 0.6

    /// Whether a garment whose box spans `garmentTop…garmentBottom` has long
    /// sleeves, from the sleeves' lowest row.
    static func longSleeves(garmentTop: Int, garmentBottom: Int, sleeveBottom: Int) -> Bool {
        let height = Double(max(1, garmentBottom - garmentTop))
        return Double(sleeveBottom - garmentTop) / height >= longSleeveReach
    }

    /// What both instructions say of a garment: its noun, its full description ("mustard
    /// striped long-sleeved jacket") and what else the person wears that must stay.
    static func words(kind: GarmentKind, noun: String?, colour: String?, longSleeves: Bool, sleeveless: Bool,
                      striped: Bool) -> (name: String, thing: String, rest: String) {
        let name = noun ?? Self.noun(kind)
        let cut = longSleeves ? "long-sleeved" : sleeveless && upperBody(kind) ? "sleeveless" : nil
        let thing = [colour, striped ? "striped" : nil, cut, name].compactMap { $0 }.joined(separator: " ")
        let rest: String
        switch kind {
        case .top, .outerwear: rest = "trousers"
        case .dress: rest = "shoes"
        case .skirt, .trousers, .shorts: rest = "top"
        case .shoes, .hat: rest = "clothes"
        }
        return (name, thing, rest)
    }

    /// The instruction for one dressing step, as a side-by-side edit sees
    /// it: the person on the left, the garment on the right. Names the
    /// garment's kind (and long sleeves), asks for its colours, pattern and
    /// cut as shown, and says what stays. `sleeveless`: the garment's picture
    /// showed no sleeves — said, because a sleeveless dress put on a woman
    /// in a t-shirt kept the t-shirt's sleeves. `colour` words go in only when a
    /// caller passes them: measured, "red and white" without "striped" made
    /// a striped top a plain red one with a white hem. `striped`
    /// (``StripeReader``) says so, and asks for the stripes as many and as
    /// wide as shown: the striped top's white bands came back thinner than
    /// its own without it (23% of the garment against 35%), and with it and
    /// its colours named, 32% — seeds 11, 12, 13 in the README.
    static func instruction(kind: GarmentKind, noun: String? = nil, colour: String? = nil, longSleeves: Bool = false,
                            sleeveless: Bool = false, striped: Bool = false) -> String {
        let (name, thing, rest) = words(kind: kind, noun: noun, colour: colour, longSleeves: longSleeves,
                                        sleeveless: sleeveless, striped: striped)
        return "Dress the person on the left in the \(thing) shown on the right, in place of what they are wearing there: "
            + "the same \(name), with exactly its colours, pattern and cut"
            + (striped ? ": its stripes as many and as wide as shown" : "")
            + (longSleeves ? ", its sleeves down to the wrists" : "")
            + ". Keep their face, hair, pose, \(rest) and the background exactly as they are. Leave the right side as it is."
    }

    /// FLUX.3's instruction for the same change: the person is the first image and the garment
    /// the second, written out as FLUX.3 was trained to read — what changes, its end state and
    /// its knock-on effects, then what stays.
    static func flux3Instruction(kind: GarmentKind, noun: String? = nil, colour: String? = nil, longSleeves: Bool = false,
                                 sleeveless: Bool = false, striped: Bool = false) -> String {
        let (name, thing, rest) = words(kind: kind, noun: noun, colour: colour, longSleeves: longSleeves,
                                        sleeveless: sleeveless, striped: striped)
        return "Dress the person in the first image in the \(thing) from the second image, in place of what they are wearing there: "
            + "the same \(name), with exactly its colours, pattern and cut"
            + (striped ? ", its stripes as many and as wide as shown" : "")
            + (longSleeves ? ", its sleeves down to the wrists" : "")
            + ", fitted naturally to their body and pose, with folds, light and shadows that match the photograph. "
            + "Keep their face, hair, pose, \(rest) and the background exactly as they are."
    }
}
