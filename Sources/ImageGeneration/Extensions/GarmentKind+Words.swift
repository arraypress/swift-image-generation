//
//  GarmentKind+Words.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

public extension GarmentKind {

    /// The kind a word names — `tshirt`, `blazer`, `jeans`, `sneakers`, or a
    /// kind's own name; `nil` for a word this does not know.
    init?(word: String) {
        guard let kind = GarmentText.kind(named: word) else { return nil }
        self = kind
    }

    /// The word SAM 3 is asked for on a garment's own picture to tell its kind.
    var classWord: String { GarmentText.classWords[self] ?? rawValue }

    /// The kind a garment picture is, from each kind's best SAM 3 score
    /// (``classWord``): the highest at or above `minimum`, a near-tie going
    /// to the more particular kind (a dress over a top). `nil` when none passes.
    static func classify(_ scores: [GarmentKind: Double], minimum: Double) -> GarmentKind? {
        GarmentText.classify(scores, minimum: minimum)
    }

    /// Whether it is worn on the upper body, where its sleeves matter.
    var upperBody: Bool { GarmentText.upperBody(self) }

    /// What to replace on the person: the regions to look for, the arm
    /// included for an upper-body garment with `sleeved` ones.
    func regions(sleeved: Bool) -> [GarmentRegion] { GarmentText.regions(for: self, sleeved: sleeved) }

    /// Its name in an instruction ("jacket" for outerwear).
    var noun: String { GarmentText.noun(self) }

    /// The instruction for dressing the person on the left of a side-by-side
    /// edit in it, shown on the right (``ImageGenerator/edit(_:_:within:showing:seed:strength:allowText:steps:person:enlarge:progress:)``).
    /// `striped` (``ReferenceFraming/isStriped(_:mask:)``) names the stripes and asks for them as wide as shown.
    func instruction(noun: String? = nil, colour: String? = nil, longSleeves: Bool = false, sleeveless: Bool = false,
                     striped: Bool = false) -> String {
        GarmentText.instruction(kind: self, noun: noun, colour: colour, longSleeves: longSleeves, sleeveless: sleeveless,
                                striped: striped)
    }

    /// Whether a garment has long sleeves, from its box's top and bottom rows
    /// and its sleeves' lowest row on its own picture.
    static func longSleeves(garmentTop: Int, garmentBottom: Int, sleeveBottom: Int) -> Bool {
        GarmentText.longSleeves(garmentTop: garmentTop, garmentBottom: garmentBottom, sleeveBottom: sleeveBottom)
    }
}
