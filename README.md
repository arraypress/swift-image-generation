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
| per picture, loaded | 19.1 s | 1.83 s |
| first picture in a fresh process | 46.6 s | 28.7 s |
| peak memory | 8.6 GB (4.6 GB with `lowMemory`) | 3.0 GB |
| disk | 13 GB (+7.3 GB for editing) | 8.2 GB |
| licence | Apache-2.0 | Apache-2.0 + MIT + Gemma Terms of Use |

Z-Image Turbo matched FLUX on quality at 13× the time; GLM-Image's only Core AI build is compiled
for M4-class GPUs. Both exports are Apple's official recipe
([apple/coreai-models](https://github.com/apple/coreai-models), BSD-3), float16/bfloat16, no
quantization, hosted at [arraypress/imagine-flux2-klein-4b](https://huggingface.co/arraypress/imagine-flux2-klein-4b)
and [arraypress/imagine-sana-sprint-1.6b](https://huggingface.co/arraypress/imagine-sana-sprint-1.6b)
with their licences and notices. This library takes the export folder; fetching it is the caller's
job (the `imagine` CLI does it on first use).

- **1024 × 1024 only.** Both were exported at that size; others need another export.
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
that seeds count up, that SANA refuses to edit and that FLUX edits.

## Requirements

macOS 27 / iOS 27 (Core AI), Swift 6.2. Apple's `coreai-models` 1.x.

## Licence

MIT for this library — see LICENSE. The models carry their own licences, listed above.
