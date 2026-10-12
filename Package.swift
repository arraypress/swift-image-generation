// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ImageGeneration",
    platforms: [
        // Core AI: the runtime both models run on.
        .macOS("27.0"), .iOS("27.0"),
    ],
    products: [
        .library(name: "ImageGeneration", targets: ["ImageGeneration"]),
    ],
    dependencies: [
        // Apple's official Core AI recipes and runtime (BSD-3): the FLUX.2 and
        // SANA Sprint pipelines — schedulers, tokenizers, VAE codecs. A fork of
        // 1.0.0 with one change: exports may be non-square (image_width /
        // image_height in the metadata), which Apple's pipeline assumed away.
        .package(url: "https://github.com/arraypress/coreai-models.git", exact: "1.0.0-nonsquare.2"),
    ],
    targets: [
        // NonisolatedNonsendingByDefault stays OFF: generation is seconds of
        // GPU work behind an async call, which must not run on a main-actor
        // caller's executor.
        .target(
            name: "ImageGeneration",
            dependencies: [.product(name: "CoreAIDiffusion", package: "coreai-models")]),
        .testTarget(name: "ImageGenerationTests", dependencies: ["ImageGeneration"]),
    ]
)

// Swift 7's import rule, today: a file must import every module whose members
// it uses, rather than leaning on another file's imports.
for target in package.targets where target.type != .system && target.type != .binary && target.type != .plugin {
    target.swiftSettings = (target.swiftSettings ?? []) + [.enableUpcomingFeature("MemberImportVisibility")]
}
