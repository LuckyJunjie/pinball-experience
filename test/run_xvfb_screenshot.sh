#!/bin/bash
# Xvfb + Godot 自动化截图脚本
# 适用于 Linux/树莓派环境

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_VERSION="4.5.1"
GODOT_FILE="Godot_v${GODOT_VERSION}-stable_linux.x86_64"

echo "===== Xvfb + Godot 自动化截图测试 ====="

# 检查 Xvfb
if ! command -v xvfb-run &> /dev/null; then
    echo "安装 Xvfb..."
    sudo apt-get update
    sudo apt-get install -y xvfb
fi

# 下载 Godot (如果不存在)
if [ ! -f "$PROJECT_DIR/$GODOT_FILE" ]; then
    echo "下载 Godot $GODOT_VERSION..."
    cd "$PROJECT_DIR"
    wget -q "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${GODOT_FILE}.zip"
    unzip -q "${GODOT_FILE}.zip"
    chmod +x "$GODOT_FILE"
fi

cd "$PROJECT_DIR"

# 运行测试
echo "运行自动化截图测试..."
xvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" \
    ./$GODOT_FILE \
    --headless \
    --path . \
    --script test/automated_screenshot_test.gd

echo ""
echo "===== 测试完成 ====="
echo "截图保存在: user://test_screenshots/"
echo "测试报告: user://test_report.json"

# 显示结果
if [ -f "test_report.json" ]; then
    echo ""
    cat test_report.json
fi
