// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "SiamSafe_swftpg",
    platforms: [.iOS("17.0")],
    products: [
        .iOSApplication(
            name: "SiamSafe",
            targets: ["AppModule"],
            bundleIdentifier: "com.dekphon.SiamSafe.playground",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .init(rawValue: "shield.fill")),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [.phone, .pad],
            supportedInterfaceOrientations: [.portrait, .landscapeLeft, .landscapeRight],
            capabilities: [
                .locationWhenInUse(purposeString: "ใช้ตำแหน่งเพื่อแสดงเหตุการณ์ใกล้คุณ / Show incidents near your location"),
                .outgoingNetworkConnections()
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources",
            exclude: ["GoogleService-Info.plist", "Item.swift"],
            resources: [.process("Assets.xcassets")]
        )
    ]
)
