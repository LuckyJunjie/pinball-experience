#!/usr/bin/env python3
"""Mac OS 上的 Godot 窗口截图工具"""
import subprocess
import time
import os
import json

PROJECT_DIR = os.path.expanduser("~/Projects/pinball-experience")
OUTPUT_FILE = os.path.join(PROJECT_DIR, "screenshots", "auto", "godot_window.png")

def kill_godot():
    subprocess.run(["pkill", "-9", "Godot"], capture_output=True)
    time.sleep(1)

def start_godot():
    print("启动 Godot...")
    subprocess.Popen([
        "open", "-a", "Godot", 
        "--args", "--path", PROJECT_DIR
    ])
    time.sleep(20)  # 等待 Godot 启动

def capture_screenshot():
    print("尝试截图...")
    # 使用 screencapture 截取屏幕
    result = subprocess.run([
        "/usr/sbin/screencapture",
        "-x", OUTPUT_FILE
    ], capture_output=True, text=True)
    
    if os.path.exists(OUTPUT_FILE):
        size = os.path.getsize(OUTPUT_FILE)
        if size > 1000:  # 文件大小大于 1KB
            print(f"✓ 截图成功: {OUTPUT_FILE} ({size} bytes)")
            return True
        else:
            print(f"⚠ 截图文件太小: {size} bytes")
            os.remove(OUTPUT_FILE)
    
    # 备选方案：使用窗口模式截图
    print("尝试窗口截图...")
    result = subprocess.run([
        "/usr/sbin/screencapture",
        "-iW",  # 交互式窗口选择
        OUTPUT_FILE
    ], capture_output=True, text=True)
    
    return os.path.exists(OUTPUT_FILE)

def main():
    kill_godot()
    
    # 启动 Godot
    start_godot()
    
    # 尝试截图
    success = capture_screenshot()
    
    # 关闭 Godot
    kill_godot()
    
    if success:
        print("完成!")
    else:
        print("截图失败")

if __name__ == "__main__":
    main()
