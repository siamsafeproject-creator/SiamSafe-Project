# SiamSafe

Two versions of the SiamSafe incident map application.

- **Xcode:** Open `Xcode/SiamSafe.xcodeproj` and allow Swift Package Manager to resolve Firebase dependencies.
- **Swift Playgrounds:** Open `Playgrounds/SiamSafe_swftpg.swiftpm`. See `Playgrounds/README.md` for setup and validation details.

Both versions use the same Firestore project. Creating or deleting events changes the shared live data. The Playgrounds version uses REST instead of the Firebase SDK and includes an offline demo switch.

Firebase client configuration is included; it is not an administrative credential. Access remains controlled by Firebase Security Rules.
