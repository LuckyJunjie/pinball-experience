#!/usr/bin/env python3
"""
Godot自动化截图测试脚本
支持命令行触发截图，捕获游戏任意时刻
"""

import subprocess
import os
import time
import argparse
import sys

# Godot路径配置
GODOT_PATH = r"D:\game_development\godot\Godot_v4.5.1-stable_win64.exe"
PROJECT_PATH = r"C:\Users\panju\.openclaw\workspace\pinball-experience"

# 截图事件类型
SCREENSHOT_EVENTS = {
    "start": "--screenshot",           # 游戏开始截图
    "launch": "--screenshot-on=ball_launch",   # 球发射时截图
    "drain": "--screenshot-on=ball_drain",    # 球掉落时截图
    "score": "--screenshot-on=score",          # 得分时截图
    "gameover": "--screenshot-on=game_over",   # 游戏结束时截图
    "delay": "--screenshot-after=3000",       # 3秒后截图
}

def run_godot(args=None, timeout=30):
    """运行Godot"""
    cmd = [GODOT_PATH, "--path", PROJECT_PATH]
    
    if args:
        cmd.extend(args)
    
    print(f"运行命令: {' '.join(cmd)}")
    
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=PROJECT_PATH
    )
    
    try:
        stdout, stderr = proc.communicate(timeout=timeout)
        return proc.returncode, stdout.decode('utf-8', errors='ignore'), stderr.decode('utf-8', errors='ignore')
    except subprocess.TimeoutExpired:
        proc.kill()
        return -1, "", "Timeout"

def auto_test_screenshot(event="start", duration=10):
    """自动测试截图"""
    print(f"\n{'='*50}")
    print(f"自动截图测试 - 事件: {event}")
    print(f"{'='*50}\n")
    
    # 获取截图参数
    screenshot_arg = SCREENSHOT_EVENTS.get(event, "--screenshot")
    
    # 运行游戏
    returncode, stdout, stderr = run_godot([screenshot_arg], timeout=duration)
    
    print(f"\n返回码: {returncode}")
    if stderr:
        print(f"错误输出: {stderr[:500]}")
    
    # 检查截图文件
    screenshot_dir = os.path.join(PROJECT_PATH, "screenshots")
    if os.path.exists(screenshot_dir):
        files = [f for f in os.listdir(screenshot_dir) if f.endswith('.png')]
        print(f"\n截图目录: {screenshot_dir}")
        print(f"找到 {len(files)} 个截图文件:")
        for f in sorted(files)[-5:]:
            print(f"  - {f}")
    
    return returncode

def interactive_mode():
    """交互模式 - 手动控制游戏并截图"""
    print("\n" + "="*50)
    print("交互模式")
    print("="*50)
    print("\n按键说明:")
    print("  SPACE/DOWN - 发射球")
    print("  LEFT/A - 左挡板")
    print("  RIGHT/D - 右挡板")
    print("  S - 手动截图")
    print("  Q - 退出")
    print("\n运行游戏...\n")
    
    run_godot(["--screenshot-on=ball_launch"])

def main():
    parser = argparse.ArgumentParser(description="Godot自动化截图测试")
    parser.add_argument("--event", "-e", choices=list(SCREENSHOT_EVENTS.keys()), 
                       default="start", help="截图触发事件")
    parser.add_argument("--duration", "-d", type=int, default=10, 
                       help="运行时间（秒）")
    parser.add_argument("--interactive", "-i", action="store_true",
                       help="交互模式")
    parser.add_argument("--custom", "-c", type=str,
                       help="自定义截图参数")
    
    args = parser.parse_args()
    
    if args.interactive:
        interactive_mode()
    elif args.custom:
        run_godot([args.custom], timeout=args.duration)
    else:
        auto_test_screenshot(args.event, args.duration)

if __name__ == "__main__":
    main()
