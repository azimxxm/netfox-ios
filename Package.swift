// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "netfox",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "netfox",
            targets: ["netfox"]
        ),
    ],
    targets: [
        .target(
            name: "netfox",
            path: "netfox/",
            exclude: ["OSX"],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
