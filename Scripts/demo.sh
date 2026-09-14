#!/usr/bin/env bash
#
# Generates and opens the Xcode project for the demo app.
#
# Usage: ./Scripts/demo.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEMO_DIR="${ROOT_DIR}/Demo"
PROJECT="${DEMO_DIR}/TKRubberPageControlDemo.xcodeproj"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "error: xcodegen is not installed." >&2
  echo "Install it with Homebrew or Mint:" >&2
  echo "  brew install xcodegen" >&2
  echo "  mint install yonaskolb/XcodeGen" >&2
  exit 1
fi

cd "${DEMO_DIR}"
xcodegen generate

if [ ! -d "${PROJECT}" ]; then
  echo "error: expected ${PROJECT} to be generated." >&2
  exit 1
fi

echo "Generated ${PROJECT}"
open "${PROJECT}"
