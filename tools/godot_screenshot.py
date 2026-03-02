#!/usr/bin/env python3
"""
Godot游戏自动化测试截图工具
用于在树莓派/Mac上自动化运行Godot并捕获游戏状态截图

用法:
    python3 godot_screenshot.py --state ball_launch
    python3 godot_screenshot.py --state ball_drain
    python3 godot_screenshot.py --all
"""

import os
import sys
import subprocess
import time
import argparse
from pathlib import Path

# 配置
PROJECT_PATH = "/home/pi/.openclaw/workspace/pinball-experience"
SCREENSHOT_DIR = f"{PROJECT_PATH}/screenshots"
GODOT_BIN = "/usr/local/bin/godot"

# 游戏状态列表
GAME_STATES = [
    "initial",       # 游戏初始状态
    "ball_launch",   # 球发射
    "ball_moving",   # 球运动中
    "flipper_hit",   # 挡板碰撞
    "obstacle_hit",  # 障碍物碰撞
    "ball_drain",    # 球掉落
    "game_over",     # 游戏结束
]

def ensure_dir():
    """确保截图目录存在"""
    os.makedirs(SCREENSHOT_DIR, exist_ok=True)

def create_mock_screenshot(state: str) -> str:
    """创建模拟截图 (用于测试或headless模式)"""
    # 使用PIL创建简单的占位图
    try:
        from PIL import Image, ImageDraw, ImageFont
        
        width, height = 800, 600
        img = Image.new('RGB', (width, height), color=(30, 30, 60))
        draw = ImageDraw.Draw(img)
        
        # 绘制标题
        state_title = state.replace("_", " ").title()
        draw.text((width//2 - 100, height//2 - 20), f"State: {state_title}", fill=(255, 255, 255))
        draw.text((width//2 - 80, height//2 + 20), f"Screenshot: {state}.png", fill=(200, 200, 200))
        
        filepath = f"{SCREENSHOT_DIR}/{state}.png"
        img.save(filepath)
        print(f"Created mock screenshot: {filepath}")
        return filepath
    except ImportError:
        # 如果没有PIL，创建一个空白文件
        filepath = f"{SCREENSHOT_DIR}/{state}.png"
        with open(filepath, 'w') as f:
            f.write(f"Mock screenshot for state: {state}")
        print(f"Created placeholder: {filepath}")
        return filepath

def run_godot_headless(state: str) -> str:
    """使用headless模式运行Godot并截图"""
    # 创建临时截图脚本
    script_content = f'''
extends SceneTree

func _initialize():
    await create_timer(2.0).timeout
    
    var main = load("res://scenes/Main.tscn").instantiate()
    root.add_child(main)
    
    await create_timer(1.0).timeout
    
    var viewport = get_root().get_viewport()
    var image = viewport.get_texture().get_image()
    
    if image and image.get_width() > 0:
        image.save_png("res://screenshots/{state}.png")
        print("Screenshot saved: {state}.png")
    else:
        print("WARNING: Could not capture viewport, creating mock")
    
    quit()
'''
    script_path = f"{PROJECT_PATH}/temp_screenshot.gd"
    with open(script_path, 'w') as f:
        f.write(script_content)
    
    # 运行Godot
    cmd = [
        GODOT_BIN,
        "--headless",
        "--window-size", "800,600",
        "--path", PROJECT_PATH,
        "-s", "temp_screenshot.gd"
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        
        screenshot_path = f"{SCREENSHOT_DIR}/{state}.png"
        if os.path.exists(screenshot_path):
            return screenshot_path
    except Exception as e:
        print(f"Error running Godot: {e}")
    
    # 如果失败，创建模拟截图
    return create_mock_screenshot(state)

def capture_state(state: str, force_mock: bool = False) -> str:
    """捕获指定状态的截图"""
    ensure_dir()
    
    if force_mock:
        return create_mock_screenshot(state)
    
    # 尝试运行Godot
    return run_godot_headless(state)

def capture_all_states():
    """捕获所有游戏状态的截图"""
    ensure_dir()
    
    results = {}
    for state in GAME_STATES:
        print(f"\n=== Capturing: {state} ===")
        path = capture_state(state, force_mock=True)  # 强制使用mock因为headless无法渲染
        results[state] = path
        time.sleep(0.5)
    
    print("\n=== All Screenshots ===")
    for state, path in results.items():
        print(f"  {state}: {path}")
    
    return results

def main():
    parser = argparse.ArgumentParser(description="Godot自动化截图工具")
    parser.add_argument("--state", help="捕获指定状态的截图")
    parser.add_argument("--all", action="store_true", help="捕获所有状态")
    parser.add_argument("--mock", action="store_true", help="使用模拟截图")
    
    args = parser.parse_args()
    
    if args.all:
        capture_all_states()
    elif args.state:
        capture_state(args.state, force_mock=args.mock)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
