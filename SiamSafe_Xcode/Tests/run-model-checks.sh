#!/bin/bash
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
check_dir="$(mktemp -d "${TMPDIR:-/tmp}/siamsafe-checks.XXXXXX")"
trap 'rm -rf "$check_dir"' EXIT
python3 - "$repo_root" "$check_dir" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1]) / 'SiamSafe'
out = Path(sys.argv[2])
# DisasterEvent does not use Firebase types; omit its unused import for this
# standalone macOS runner. All model and runtime logic is copied unmodified.
(out/'DisasterEvent.swift').write_text((root/'ViewModels/DisasterEvent.swift').read_text().replace('import FirebaseFirestore\n', ''))
service = (root/'Service/FirebaseService.swift').read_text()
protocol = service[service.index('@MainActor'):service.index('final class FirebaseService')]
(out/'EventService.swift').write_text('import Foundation\n' + protocol)
app = (root/'SiamSafeApp.swift').read_text()
(out/'RuntimeEnvironment.swift').write_text('import Foundation\n' + app[app.index('enum RuntimeEnvironment'):app.index('@main')])
PY
xcrun swiftc -parse-as-library "$check_dir/DisasterEvent.swift" "$check_dir/EventService.swift" \
    "$check_dir/RuntimeEnvironment.swift" "$repo_root/SiamSafe/ViewModels/ReportViewModel.swift" \
    "$repo_root/Tests/ReportViewModelChecks.swift" -o "$check_dir/checks"
env -u XCODE_RUNNING_FOR_PREVIEWS -u XCODE_RUNNING_FOR_PLAYGROUNDS "$check_dir/checks"
