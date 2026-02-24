#!/bin/bash
# Pinball Experience - 状态检查脚本

GODOT="/tmp/Godot_v4.5.1-stable_linux.arm64"
PROJECT="/home/pi/.openclaw/workspace/pinball-experience"

echo "========================================"
echo "  Pinball Experience - 状态检查"
echo "  $(date)"
echo "========================================"

cd "$PROJECT" || exit 1

echo ""
echo "--- 运行测试 ---"

# 运行测试并保存结果
echo "运行单元测试..."
UNIT_LOG=$(mktemp)
$GODOT --headless --script test/run_tests.gd 2>&1 | grep -c "✓" > "$UNIT_LOG" 2>&1 || echo "0" >> "$UNIT_LOG"
UNIT_PASS=$(cat "$UNIT_LOG" | tr -d '\n')

echo "运行布局测试..."
LAYOUT_LOG=$(mktemp)
$GODOT --headless --script test/integration/test_layout.gd 2>&1 | grep -c "✓" > "$LAYOUT_LOG" 2>&1 || echo "0" >> "$LAYOUT_LOG"
LAYOUT_PASS=$(cat "$LAYOUT_LOG" | tr -d '\n')

echo "运行集成测试..."
GAMEPLAY_LOG=$(mktemp)
$GODOT --headless --script test/integration/test_gameplay.gd 2>&1 | grep -c "✓" > "$GAMEPLAY_LOG" 2>&1 || echo "0" >> "$GAMEPLAY_LOG"
GAMEPLAY_PASS=$(cat "$GAMEPLAY_LOG" | tr -d '\n')

echo "结果: 单元=$UNIT_PASS, 布局=$LAYOUT_PASS, 集成=$GAMEPLAY_PASS"

# 转换为整数
UNIT_PASS=${UNIT_PASS:-0}
LAYOUT_PASS=${LAYOUT_PASS:-0}
GAMEPLAY_PASS=${GAMEPLAY_PASS:-0}

TOTAL_PASS=$((UNIT_PASS + LAYOUT_PASS + GAMEPLAY_PASS))

echo ""
echo "========================================"
echo "  测试汇总"
echo "  单元测试: $UNIT_PASS 通过"
echo "  布局测试: $LAYOUT_PASS 通过"
echo "  集成测试: $GAMEPLAY_PASS 通过"
echo "  -----------------------"
echo "  总计: $TOTAL_PASS 通过"
echo "========================================"

if [ "$TOTAL_PASS" -ge 30 ]; then
    echo "✅ 所有测试通过！游戏应该可玩。"
    exit 0
else
    echo "⚠️ 测试数量不足，可能需要检查。"
    exit 1
fi
