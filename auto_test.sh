#!/bin/bash
# Godot 自动测试截图脚本

PROJECT_DIR="$HOME/Projects/pinball-experience"
OUTPUT_DIR="$PROJECT_DIR/screenshots/auto"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "开始自动测试..."

# 杀掉之前的 Godot 进程
pkill -9 Godot 2>/dev/null
sleep 1

# 启动 Godot 并运行项目
open -a Godot --args --path "$PROJECT_DIR"

# 等待 Godot 启动
echo "等待 Godot 启动..."
sleep 15

# 尝试截取屏幕
echo "尝试截图..."
/usr/sbin/screencapture -x "$OUTPUT_DIR/godot_screen.png" 2>&1

if [ -f "$OUTPUT_DIR/godot_screen.png" ]; then
    echo "截图成功: $OUTPUT_DIR/godot_screen.png"
    ls -la "$OUTPUT_DIR/godot_screen.png"
else
    echo "截图失败，尝试使用窗口截图..."
    # 尝试获取窗口列表
    /usr/sbin/screencapture -iW "$OUTPUT_DIR/window_capture.png" 2>&1
fi

# 关闭 Godot
pkill -9 Godot 2>/dev/null

echo "完成"
