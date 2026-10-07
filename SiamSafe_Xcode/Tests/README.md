# SiamSafe regression checks

Run `bash Tests/run-model-checks.sh` on macOS with Xcode selected.

This offline runner compiles the production `ReportViewModel`, `EventService`
protocol, runtime mode logic, and event types against a deterministic service
fake. It never connects to Firebase or changes production data. No package or
Xcode project changes are required.

It covers active/resolved query separation, ordering and urgent counts, failed
reads and retry, stale responses after creation, overlapping refreshes, partial
deletion, failed refresh after deletion, duplicate deletion protection, and
preview isolation. This does not replace UI testing or backend rule validation.

Build the app separately for both iOS Simulator and iOS to verify SwiftUI and
Firebase integration. If Canvas is building, use a separate derived data path
to avoid contention with Xcode's build database.
