#!/usr/bin/env bash
# Run unit tests and capture screenshot (latest only).
# Usage: ./run_all_tests.sh
# Requires: godot in PATH (Godot 4.x)

set -e
cd "$(dirname "$0")"

GODOT="${GODOT:-godot}"
if ! command -v "$GODOT" &>/dev/null; then
  echo "Error: godot not found. Set GODOT=/path/to/godot or add godot to PATH."
  exit 1
fi

echo "=== 1. Running GUT unit tests ==="
"$GODOT" --headless -s addons/gut/gut_cmdln.gd -gdir=res://test/unit/ -gexit

echo ""
echo "=== 2. Capturing screenshot (overwrites latest) ==="
"$GODOT" --headless -s scripts/run_tests_with_screenshot.gd

echo ""
echo "=== All tests and screenshot complete ==="
