# Pinball Experience - CI/CD 测试脚本
# 运行四层测试金字塔

#!/bin/bash

set -e

echo "========================================"
echo "  Pinball Experience - CI 测试"
echo "========================================"

# 设置 Godot 路径
GODOT="/tmp/Godot_v4.5.1-stable_linux.arm64"

# 如果 Godot 不存在，下载
if [ ! -f "$GODOT" ]; then
    echo "下载 Godot 4.5.1..."
    cd /tmp
    curl -L -o godot.zip "https://ghfast.top/https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_linux.arm64.zip"
    unzip -o godot.zip
    chmod +x Godot_v4.5.1-stable_linux.arm64
fi

cd /home/pi/.openclaw/workspace/pinball-experience

echo ""
echo "========================================"
echo "  第一层: 单元测试"
echo "========================================"
echo "运行场景结构测试..."
$GODOT --headless --script test/run_tests.gd 2>&1 | tee test/unit_results.log

echo ""
echo "========================================"
echo "  第二层: 集成测试"
echo "========================================"
echo "运行集成测试..."
# TODO: 添加更多集成测试

echo ""
echo "========================================"
echo "  第三层: 截图测试"
echo "========================================"
echo "截图测试需要 Godot 编辑器环境"
# TODO: 添加截图测试

echo ""
echo "========================================"
echo "  第四层: 性能测试"
echo "========================================"
echo "性能测试需要 Godot 编辑器环境"
# TODO: 添加性能测试

echo ""
echo "========================================"
echo "  控制台测试"
echo "========================================"
echo "运行控制台测试..."
$GODOT --headless --quit-after 3 2>&1 | tee test/console_results.log

echo ""
echo "========================================"
echo "  CI 测试完成"
echo "========================================"
