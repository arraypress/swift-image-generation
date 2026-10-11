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

Two, chosen by measurement on an M3 Max (2026-10-11) from five candidates on the same eight
prompts — FLUX.2 Klein 4B, SANA Sprint 0.6B and 1.6B, Z-Image Turbo and GLM-Image:

| | FLUX.2 [klein] 4B | SANA Sprint 1.6B |
|---|---|---|
| role | quality; the only one to spell a short sign right; **edits** pictures | drafts; ~10× faster |
| per picture, loaded (1:1) | 19.1 s | 1.83 s |
| 16:9 against 1:1, back to back | ~1.1–1.3× | ~1.7× (4.0 s vs 2.4 s) |
| first picture in a fresh process | 46.6 s | 28.7 s |
| peak memory | 8.6 GB (4.6 GB with `lowMemory`) | 3.0 GB |
| disk | 13 GB (+7.3 GB editing, +7.3 GB 16:9) | 8.2 GB (+3.3 GB 16:9) |
| licence | Apache-2.0 | Apache-2.0 + MIT + Gemma Terms of Use |

Z-Image Turbo matched FLUX on quality at 13× the time; GLM-Image's only Core AI build is compiled
for M4-class GPUs. Both exports are Apple's official recipe
([apple/coreai-models](https://github.com/apple/coreai-models), BSD-3), float16/bfloat16, no
quantization, hosted at [arraypress/imagine-flux2-klein-4b](https://huggingface.co/arraypress/imagine-flux2-klein-4b)
and [arraypress/imagine-sana-sprint-1.6b](https://huggingface.co/arraypress/imagine-sana-sprint-1.6b)
with their licences and notices. This library takes the export folder; fetching it is the caller's
job (the `imagine` CLI does it on first use).

- **Two shapes: 1:1 (1024 × 1024) and 16:9 (1344 × 768).** `ImageAspect` names them; a 16:9
  export is its own folder (`aspect-16x9/`) beside the square one, sharing its text encoder, and
  `ImageGenerator(bundle:)` loads either — `size` says which. Measured before choosing that layout: a
  transformer holding both shapes as two functions shares one 7.2 GB weight copy on disk, but Core AI
  compiles every function at first load and keeps a full compiled copy of each (14 GB), so everyone
  would pay for every shape; a folder per shape costs only whoever uses it — FLUX 7.3 GB, SANA 3.3 GB
  of download and about as much compiled cache. 9:16 and 4:5 would cost the same each and are not
  exported yet. Editing is 1:1 only.
- **A fork of Apple's pipeline, for 16:9.** Apple's `FlowTransformerPipeline` assumes a square image
  (one `spatialSide` for the token grid and the decode). This depends on
  [arraypress/coreai-models](https://github.com/arraypress/coreai-models) `1.0.0-nonsquare.1`: Apple's
  1.0.0 plus a 45-line change reading `image_width`/`image_height` from an export's metadata. Square
  output is pixel-identical to Apple's pipeline (measured, both models); Apple's 79 diffusion tests pass.
- **Deterministic.** The same model, prompt and seed make the same picture, byte for byte. A run
  of *n* uses seeds `seed…seed+n−1`, so any picture can be remade alone from its seed.
- **No text by default.** Both models misspell anything longer than a short word and invent
  lettering when a prompt merely suggests it ("cover art for a sound effects pack" came back with
  "SOIN SOON PACK"). Neither takes a negative prompt, so `generate` appends *"no text, no letters,
  no typography"* — measured, that removed the invented lettering — unless `allowText: true`.
  Draw real text afterwards with proper type.
- **Editing** is FLUX only, and needs `Transformer_img2img_full.aimodel` and `VAEEncoder.aimodel`
  beside the rest (`supportsEditing`). The source is cropped to its centred square first. `strength`
  is Apple's: 0.85 by default, 0.8–0.9 to change content, 0.5–0.75 for style.
- **Marked as AI-generated.** `GeneratedImage.write(to:generator:embedPrompt:)` writes PNG, JPEG
  or HEIC carrying the IPTC digital-source type `trainedAlgorithmicMedia`, the model as IPTC
  `AISystemUsed` and your tool as `xmp:CreatorTool` (checked with exiftool). The prompt is written
  only with `embedPrompt: true`. The SDK has no C2PA API, so there are no signed credentials.
- **Not on iPhone.** Neither model fits an iPhone's per-app memory (~6.1 GB on a 12 GB phone):
  FLUX peaks at 8.6 GB, and SANA's Gemma text encoder alone is 4.9 GB. The package builds for iOS
  27 (checked with `generic/platform=iOS`; the iOS Simulator SDK has no Core AI at all).
- **First load compiles.** Core AI compiles an export for the GPU on first load and caches it per
  program under `~/Library/Caches/coreai-cache/<OS build>/<program>` — about the model's own size.
  Test runners and scratch tools each get their own copy; that cache is safe to delete.

## Testing

`swift test` runs prompts, seeds, cropping, export recognition and provenance (PNG/JPEG/HEIC) with
no model. With the exports named — `IMAGE_GENERATION_FLUX=<folder> IMAGE_GENERATION_SANA=<folder>
swift test` — it also checks, on the real models, that a seed reproduces its picture byte for byte,
that seeds count up, that SANA refuses to edit, that FLUX edits, and (with an `aspect-16x9/` folder
beside the SANA export) that 16:9 comes out 1344 × 768 and deterministic.

## Requirements

macOS 27 / iOS 27 (Core AI), Swift 6.2. `coreai-models` — the arraypress fork of Apple's 1.0.0 (see
above), pinned exactly.

## Licence

MIT for this library — see LICENSE. The models carry their own licences, listed above.
