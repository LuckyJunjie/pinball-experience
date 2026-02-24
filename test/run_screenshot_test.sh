#!/bin/bash
# Automated Screenshot Test Runner
# Usage: ./run_screenshot_test.sh

set -e

echo "========================================"
echo "  Automated Screenshot Test Runner"
echo "========================================"

# Configuration
PROJECT_DIR="/home/pi/.openclaw/workspace/pinball-experience"
GODOT="/usr/local/bin/godot4.5.1"
DISPLAY_NUM=99

# Start Xvfb if not running
if ! pgrep -x "Xvfb" > /dev/null; then
    echo "Starting Xvfb..."
    Xvfb :$DISPLAY_NUM -screen 0 800x600x24 -ac &
    sleep 2
fi

# Run the test
cd "$PROJECT_DIR"
echo "Running screenshot test..."
DISPLAY=:$DISPLAY_NUM $GODOT --rendering-method gl_compatibility --display-driver x11 --quit-after 5 -s res://test/auto_screenshot_test.gd 2>&1 | grep -v "^Godot\|^WARNING:\|^ERROR:\|^   at:"

echo ""
echo "========================================"
echo "  Test Complete"
echo "========================================"

# Show results
echo ""
echo "Baseline:   $PROJECT_DIR/screenshots/base/"
echo "Current:    $PROJECT_DIR/screenshots/current/"
echo "Diff:       $PROJECT_DIR/screenshots/diff/"
ls -la "$PROJECT_DIR/screenshots/base/"
ls -la "$PROJECT_DIR/screenshots/current/"
