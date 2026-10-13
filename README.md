# swift-image-generation

Pictures from words — and edits of pictures — on this machine, with Apple's Core AI.

```swift
import ImageGeneration

let generator = try await ImageGenerator(bundle: fluxFolder)
let pictures = try await generator.generate("a red bicycle against a blue door", seed: 7, count: 2)
try pictures[0].write(to: URL(fileURLWithPath: "bike.png"), generator: "my app 1.0")

let night = try await generator.edit(pictures[0].image, "make it night")
```

## Models

Two defaults, chosen by measurement on an M3 Max (2026-10-11) from five candidates on the same eight
prompts — FLUX.2 Klein 4B, SANA Sprint 0.6B and 1.6B, Z-Image Turbo and GLM-Image:

| | FLUX.2 [klein] 4B | SANA Sprint 1.6B |
|---|---|---|
| role | quality; the only one to spell a short sign right; **edits** pictures | drafts; ~10× faster |
| per picture, loaded (1:1) | 19.1 s | 1.83 s |
| 16:9 against 1:1, back to back | ~1.1–1.3× | ~1.7× (4.0 s vs 2.4 s) |
| first picture in a fresh process | 46.6 s | 28.7 s |
| peak memory | 8.6 GB (4.6 GB with `lowMemory`) | 3.0 GB |
| disk | 13 GB (+7.3 GB editing, +7.3 GB per extra shape) | 8.2 GB (+3.3 GB per extra shape) |
| licence | Apache-2.0 | Apache-2.0 + MIT + Gemma Terms of Use |

**FLUX.2 [klein] 9B** (0.3, `.flux2Klein9B`) is the opt-in third: on the same prompts a tie with 4B
on photos, worse on an app icon, **clearly better at longer text**; about 2.3× slower (median ≈110 s
a picture on a 36 GB Mac with `lowMemory`, 4.1 GB peak; all parts at once was *slower*, 176 s — see
`loadsPartsOneAtATime(physicalMemory:)`). 1:1 only, no editing, and **non-commercial** (FLUX
Non-Commercial License v2.1, `isNonCommercial`): a caller shows the terms and has them accepted, and
output must be filtered or reviewed before it is shared. The export is recognised from its own
`metadata.json` like the others.

Z-Image Turbo matched FLUX on quality at 13× the time; GLM-Image's only Core AI build is compiled
for M4-class GPUs. Both exports are Apple's official recipe
([apple/coreai-models](https://github.com/apple/coreai-models), BSD-3), float16/bfloat16, no
quantization, hosted at [arraypress/imagine-flux2-klein-4b](https://huggingface.co/arraypress/imagine-flux2-klein-4b)
and [arraypress/imagine-sana-sprint-1.6b](https://huggingface.co/arraypress/imagine-sana-sprint-1.6b)
with their licences and notices. This library takes the export folder; fetching it is the caller's
job (the `imagine` CLI does it on first use).

- **Four shapes: 1:1 (1024 × 1024), 16:9 (1344 × 768), 9:16 (768 × 1344) and 4:5 (896 × 1120).**
  `ImageAspect` names them; each non-square export is its own folder (`aspect-16x9/`, `aspect-9x16/`,
  `aspect-4x5/`) beside the square one, sharing its text encoder, and
  `ImageGenerator(bundle:)` loads either — `size` says which. Measured before choosing that layout: a
  transformer holding both shapes as two functions shares one 7.2 GB weight copy on disk, but Core AI
  compiles every function at first load and keeps a full compiled copy of each (14 GB), so everyone
  would pay for every shape; a folder per shape costs only whoever uses it — FLUX 7.3 GB, SANA 3.3 GB
  of download and about as much compiled cache, per shape. 9:16 and 4:5 (0.5.0) were exported with
  `COREAI_IMAGE_HW` from the fork's `1.0.0-nonsquare.3`; same seed, byte-identical output, measured.
  Editing is 1:1 only.
- **A fork of Apple's pipeline, for the non-square shapes.** Apple's `FlowTransformerPipeline` assumes a square image
  (one `spatialSide` for the token grid and the decode). This depends on
  [arraypress/coreai-models](https://github.com/arraypress/coreai-models) `1.0.0-nonsquare.2`: Apple's
  1.0.0 plus a 45-line change reading `image_width`/`image_height` from an export's metadata, and
  (`.2`) an ~80-line one taking several reference pictures. Square output is pixel-identical to
  Apple's pipeline (measured, both models); Apple's diffusion tests pass.
- **Deterministic.** The same model, prompt and seed make the same picture, byte for byte. A run
  of *n* uses seeds `seed…seed+n−1`, so any picture can be remade alone from its seed.
- **No text by default.** Both models misspell anything longer than a short word and invent
  lettering when a prompt merely suggests it ("cover art for a sound effects pack" came back with
  "SOIN SOON PACK"). Neither takes a negative prompt, so `generate` appends *"no text, no letters,
  no typography"* — measured, that removed the invented lettering — unless `allowText: true`.
  Draw real text afterwards with proper type.
- **Editing** is FLUX only, and needs `Transformer_img2img_full.aimodel` and `VAEEncoder.aimodel`
  beside the rest (`supportsEditing`). The source is cropped to its centred square first.
- **Strength** (0.9) is how far an edit may move from the source, 0…1, default 1. At 1 FLUX redraws
  from pure noise with the source only as a reference (what every edit did before 0.9). Below 1 it
  starts from the source itself blended with noise (fork `1.0.0-nonsquare.4`: a re-spaced schedule
  of `steps / strength` steps entered at `total − steps`, so 4 steps still run and every strength is
  reachable). Up to 0.8 the composition is the source's, exactly. Measured, SSIM to the source,
  stock owl and parrot, "make it a watercolour painting" / "relight it with warm golden hour
  sunlight", seed 7:

  | strength | 0.2 | 0.4 | 0.6 | 0.8 | 1.0 |
  |---|---|---|---|---|---|
  | owl, watercolour | 0.994 | 0.976 | 0.843 | 0.638 | 0.559 |
  | owl, golden hour | 0.994 | 0.853 | 0.748 | 0.641 | 0.515 |
  | parrot, watercolour | 0.994 | 0.992 | 0.972 | 0.637 | 0.490 |
  | parrot, golden hour | 0.994 | 0.985 | 0.923 | 0.666 | 0.553 |

  Monotonic everywhere. The big step is between 0.6 and 0.8: Klein's 4-step schedule is shifted
  hard toward noise, so the entry noise rises steeply there. 0.7–0.85 restyles while keeping the
  layout; ≤ 0.4 is a light touch. 1.0 is byte-identical to 0.8.x. SANA cannot take a strength: its
  export has no VAE encoder to bring a picture into its latents.
- **Steps.** `steps:` on `generate` and `edit` — SANA 1–4 (its export's default 2), FLUX 1–28
  (default 4; Klein is distilled for 4 — measured ~8 s a step, and 8 steps no better). Out of range throws `.invalidSteps` before any work.
- **References** (0.4). `references:` gives FLUX.2 Klein 4B further pictures to draw from, up to
  `ImageGenerator.maximumReferences` (4) counting an edited picture; each is cropped square. One
  picture in is seen whole (4,096 tokens). With more, the traced reference route still holds 4,096
  tokens, so each picture is averaged to a quarter grid and the four quarters are dealt out in turn,
  each picture on its own position offset as diffusers does (needs arraypress/coreai-models
  `1.0.0-nonsquare.2`). More than four throws `.tooManyReferences`.
- **Masked edits** (0.4). `edit(_:_:within:…)` takes `RegionMask`s (from a segmenter — `imagine`
  uses SAM 3), edits a square around them at the model's size, enlarges it back through your
  `enlarge` closure, and composites only the masked part into the full-size original:
  - masks are grown and feathered; the grown ring is admitted only where it has the object's own
    colour, so a mask that stops a pixel short is covered without a glow onto the background;
  - a plain mask keeps the original's high frequencies and takes the edit's low ones (colour and
    shading) — skin, eyes and fabric survive a recolour. `replaces: true` takes the edit's own
    detail, for things removed or added. The low-pass is a normalised blur that leaves the
    replaced zone out, so a removed object does not smear into what is kept;
  - work happens in the picture's own colour space and every pixel the mask cannot touch is the
    original's bytes; `MaskedEditReport.untouchedMaxDifference` measures it (0 in every test).
 `GeneratedImage.write(to:generator:embedPrompt:)` writes PNG, JPEG
  or HEIC carrying the IPTC digital-source type `trainedAlgorithmicMedia`, the model as IPTC
  `AISystemUsed` and your tool as `xmp:CreatorTool` (checked with exiftool). The prompt is written
  only with `embedPrompt: true`. The SDK has no C2PA API, so there are no signed credentials.
- **Not on iPhone.** Neither model fits an iPhone's per-app memory (~6.1 GB on a 12 GB phone):
  FLUX peaks at 8.6 GB, and SANA's Gemma text encoder alone is 4.9 GB. The package builds for iOS
  27 (checked with `generic/platform=iOS`; the iOS Simulator SDK has no Core AI at all).
- **First load compiles.** Core AI compiles an export for the GPU on first load and caches it per
  program under `~/Library/Caches/coreai-cache/<OS build>/<program>` — about the model's own size.
  Test runners and scratch tools each get their own copy; that cache is safe to delete.

## Face fix (0.8)

```swift
let editor = try await ImageGenerator(bundle: fluxFolder)          // FLUX.2 Klein 4B, editing parts installed
let small = try ImageGenerator.smallFaces(in: picture)             // Vision only, no model: skip the load when empty
let fixed = try await editor.fixFaces(in: picture, prompt: "a woman", seed: 7)
fixed.image          // the original's pixels everywhere but the redrawn ovals
fixed.faces          // per face: box, qualityBefore/After, shift, kept, untouchedMaxDifference
```

Small faces melt — a full-length figure's face is ~60 px of 1024. `fixFaces` finds each face no
larger than `FaceFixOptions.largestFace` of the picture's longer side (0.15), cuts a square of
`context` × the face (3.5) around it, has FLUX redraw it at 1024, and composites a soft oval over
the face through the masked-edit path (a replacing mask). Faces are judged by Vision's face capture
quality: a redraw rated below the original is discarded (`keepsOnlyImprovements`). The instruction
names only the subject (the prompt's first part) and says what to keep; the whole scene prompt made
FLUX draw a new scene in the square. `FaceFixOptions.strength` (0.9) defaults to 1, a full
redraw, because a melted face is only repaired from noise: measured at 0.4 / 0.6 / 1.0, a melted
71 px face scored 0.25 / 0.35 / 0.67 (from 0.28), a melted 118 px one 0.41 / 0.45 / 0.57 (from 0.41).
Lower strength does keep identity — a Vision feature-print distance to the old face of 0.21 / 0.23
/ 0.45 on a fine 180 px face — but it barely improved it (0.58 → 0.59 / 0.60 / 0.62), so the size
cap stays and lower strength is there only for a gentle pass. `StyleCategory.featuresPeople` says which styles have faces. Vision runs on iOS too.

Measured on an M3 Max, SANA pictures from `--style tokyo` / `old-money` over several seeds; quality
is Vision's face capture quality (0–1) before → after, by the square's size (× the face). For scale:
clean faces of the same size scored 0.43–0.54, and a 327 px studio headshot 0.80.

| Picture | Face | Before | ×2.0 | ×2.5 | ×3.5 | Moved | Outside the oval |
|---|---|---|---|---|---|---|---|
| tokyo, melted | 73 px | 0.28 | 0.65 | 0.65 | **0.68** | 2.5–3.7 px | identical |
| tokyo-21 | 54 px | 0.35 | 0.43 | 0.42 | **0.45** | 3.2–4.0 px | identical |
| tokyo-30 | 71 px | 0.49 | 0.65 | 0.68 | **0.69** | 0.7–2.2 px | identical |
| old-money-13 | 119 px | 0.41 | — | 0.59 | — | 5.5 px | identical |
| old-money-4 | 181 px | 0.58 | — | 0.63, *a different man* | — | 2.2 px | identical |

×3.5 rated best on every face, so it is the default. The size limit is 15% of the picture's side
(154 px at 1024): the 119 px face went from melted to clean, while the 181 px one was fine already
and came back as someone else — a redraw invents a face, so it is only worth it where there was no
face to keep. With `--ref`, the redraw is given the reference pictures too, so it draws that
person; that path is untested on a real likeness (no personal photos are used in tests). By eye
every redraw sat in its picture with no visible edge. Time: each face is one FLUX edit — 106–209 s
here, with the GPU shared with a training run the whole time (one 723 s outlier); unshared, a FLUX
edit is about 20 s.

## Recipes (0.6)

`ImageRecipe` is a picture as data — the prompt in named parts, the settings, the pictures it
starts from, and what made it — as versioned JSON (`"imagine": 1`). `imagine --save-recipe` writes
it and `imagine recipe` replays it; anything else drawing with these models can read the same file.

```swift
var recipe = try ImageRecipe.decode(Data(contentsOf: url))   // refuses unknown keys, naming them
recipe = try recipe.setting("style", to: "watercolour")      // one field, from command-line text
recipe.composedPrompt   // "a red bicycle, rusty chain, against a blue door, …, watercolour"
recipe.promptSent       // what the model is given, the no-text suffix included
try recipe.encoded().write(to: url)
```

The prompt is either `text` or parts composed in a fixed order — subject, details, setting,
lighting, camera, style, extra — joined with ", " (trailing punctuation on each part dropped). A
recipe holding only `text` composes to exactly that text, so a typed prompt round-trips to the
identical `promptSent`. `avoid_text` left out means the model's default: FLUX.2 Klein 9B draws text,
the others are told not to. Reading is strict on purpose: `JSONDecoder` ignores keys it does not
know, so a misspelt `"lightning"` would otherwise vanish and the picture would quietly differ.

## Styles (0.7)

116 built-in styles in 12 categories — 742 scenes — as Swift data (`ImageStyle.all`), not a
resource bundle, so they travel with a binary however it is installed. A style is a look with
several scenes: `hard-flash` is seven different shots that share a flash and a lens, not one prompt.
A scene becomes `ImageRecipe.Prompt` parts around a subject, so a picture made from a style saves as
an ordinary recipe and replays without this table.

```swift
let style = ImageStyle.named("old-money")!
let scene = style.sceneIndex(seed: 42)                   // seed % scenes: the same seed, the same scene
let prompt = style.prompt(scene: scene, subject: "a woman in her 40s", wear: .feminine)
ImageRecipe(prompt: prompt).composedPrompt
```

| Category | Styles |
|---|---|
| headshots | 14 — corporate, executive, founder, healthcare, lawyer, author, actor, chef, keynote… |
| dating | 3 — dating profile, out and about, date night |
| couples | 4 — couple portrait, engagement, wedding day, through the ages |
| lifestyle | 14 — slow weekend, mirror selfie, nature, adventure, fitness, hard flash, instant film… |
| fashion | 23 — old money, quiet luxury, dark academia, street style, try-ons, hair, beard, makeup… |
| travel | 12 — Paris, Tokyo, Greek islands, Bali, digital nomad, traditional dress… |
| retro | 8 — the 1920s to Y2K |
| seasonal | 11 — Halloween, Christmas, Diwali, Holi, Eid, Hanukkah, Lunar New Year… |
| events | 7 — festival, DJ set, club, rooftop, football, graduation, birthday |
| fantasy | 15 — fairy tale, tarot, chibi, anime, pixel art, action figure, character sheet… |
| art | 4 — fine-art portrait, tattoo, album cover, reaction face |
| food | 1 — food photography (the subject is the dish) |

`wear` picks a cut of each scene's clothes: `.neutral` (the default, wording that assumes nothing),
`.feminine` or `.masculine` where a scene has one — otherwise the neutral wording — or `.none` for a
subject that wears nothing, a pet or a dish. Nothing about gender is required.

**Where the wording comes from.** The ideas surveyed a commercial style catalogue; every scene was
written here. Measured 2026-10-13: across all 742 scenes in every wardrobe cut, composed as sent,
**no run of six words** is shared with any of that catalogue's 1,978 prompts (65,259 six-word runs,
case and punctuation ignored). Left out on purpose: celebrity look-alikes, mugshots, protests, ID
photos, anything sexual or suggestive, anything with children, and brand, venue and event names.

The text lives in `Support/StyleText/` in a small line format (described in `StyleCatalog.swift`),
so ~750 scenes stay reviewable as prose. A test fails the build on any line it cannot read.

## People: a LoRA through the slot (0.10)

```swift
let layout = try LoRASlotLayout(contentsOf: fluxFolder.appendingPathComponent("slot.json"))
let owl = try Person.importing(lora: try Data(contentsOf: loraURL), name: "owl",
                               trigger: "zxq plush owl", layout: layout)
try owl.write(to: personURL)                                   // 37 MB at rank 16

let generator = try await ImageGenerator(bundle: fluxFolder)   // generator.loraSlot != nil
let pictures = try await generator.generate("a photo of zxq plush owl, on a stack of old books",
                                            seed: 11, person: try Person(contentsOf: personURL))
```

Core AI has no adapter API: a compiled asset's weights are fixed, so merging a LoRA would cost a
7.2 GB re-export per person. Instead the FLUX.2 Klein 4B transformer is exported once with a **LoRA
slot** (`coreai.diffusion.export … --lora-slot 16` in the
[arraypress/coreai-models](https://github.com/arraypress/coreai-models) fork, 1.0.0-nonsquare.5):
each of its 80 attention projections computes `W·x + B·(A·x)` with A and B as inputs, listed in the
export's `slot.json`. A ``Person`` is a LoRA's matrices (F16, alpha/rank folded into B) plus its
trigger, in a safetensors file; ``ImageGenerator/generate(_:seed:count:allowText:steps:references:person:progress:)``
hands them to the slot, zero-padding a lower rank. With no person the slot gets zeros and the export
computes **exactly** what the plain one does.

Measured (M3 Max, rank 16): with zero matrices the transformer's output is bit-identical to the plain
export's; a LoRA through the slot against the same LoRA merged in PyTorch fp16, relative L2 0.0024 —
below the plain export's own conversion error against PyTorch (0.0039); about 2 % more time per step.
`Person.importing` takes PEFT/diffusers names (`transformer.<layer>.lora_A.weight`) and bare
`<layer>.lora_A`, and refuses — by name — layers the slot lacks, other shapes, a rank above the slot's,
and kohya files. Text to image only: the editing transformer has no slot, so a person with references
is refused. ``LoRASlotCheck`` loads a slot transformer and checks its inputs against `slot.json`.

## Testing

`swift test` runs prompts, seeds, cropping, export recognition, provenance (PNG/JPEG/HEIC) and the
face fix's geometry (which faces qualify, the square, the oval, the instruction) with no model. With the exports named — `IMAGE_GENERATION_FLUX=<folder> IMAGE_GENERATION_SANA=<folder>
swift test` — it also checks, on the real models, that a seed reproduces its picture byte for byte,
that seeds count up, that SANA refuses to edit, that FLUX edits, and (with an `aspect-16x9/` folder
beside the SANA export) that 16:9 comes out 1344 × 768 and deterministic.

## Requirements

macOS 27 / iOS 27 (Core AI), Swift 6.2. `coreai-models` — the arraypress fork of Apple's 1.0.0 (see
above), pinned exactly to `1.0.0-nonsquare.4` (strength).

## Licence

MIT for this library — see LICENSE. The models carry their own licences, listed above.
