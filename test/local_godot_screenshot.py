#!/usr/bin/env python3
"""
本地Godot自动化截图方案
1. 启动Godot（不用headless，显示窗口）
2. 等待游戏加载
3. 发送按键模拟玩家操作
4. 截取游戏窗口截图
"""

import subprocess
import time
import os
import sys
import mss
from PIL import Image

# 配置
GODOT_PATH = r"D:\game_development\godot\Godot_v4.5.1-stable_win64.exe"
PROJECT_PATH = r"C:\Users\panju\.openclaw\workspace\pinball-experience"
SCREENSHOT_DIR = os.path.join(PROJECT_PATH, "screenshots", "local")

def ensure_dir(path):
    os.makedirs(path, exist_ok=True)

def start_godot():
    """启动Godot（显示窗口，使用OpenGL兼容性模式）"""
    print("启动Godot (OpenGL)...")
    # 使用 --quit-after 让游戏运行一段时间后自动退出
    # CREATE_NO_WINDOW 标志让窗口正常显示
    proc = subprocess.Popen(
        [GODOT_PATH, "--path", PROJECT_PATH, "--rendering-method", "gl_compatibility", "--quit-after", "15"],
        cwd=PROJECT_PATH,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    print(f"Godot PID: {proc.pid}")
    time.sleep(2)  # 等待窗口创建
    return proc

def activate_window(title_pattern="Godot"):
    """激活Godot窗口"""
    try:
        import win32gui
        import win32con
        
        def find_window(hwnd, windows):
            if win32gui.IsWindowVisible(hwnd):
                title = win32gui.GetWindowText(hwnd)
                if title and title_pattern.lower() in title.lower():
                    windows.append((hwnd, title))
        
        windows = []
        win32gui.EnumWindows(find_window, windows)
        
        if windows:
            print(f"找到窗口: {[w[1] for w in windows]}")
            hwnd, title = windows[0]
            win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
            win32gui.SetForegroundWindow(hwnd)
            print(f"已激活窗口: {title}")
            return True
        else:
            # 列出所有可见窗口
            all_windows = []
            win32gui.EnumWindows(find_window, all_windows)
            print(f"所有可见窗口: {[w[1] for w in all_windows[:10]]}")
    except Exception as e:
        print(f"激活窗口失败: {e}")
    return False

def wait_for_game(seconds=5):
    """等待游戏加载"""
    print(f"等待游戏加载 {seconds}秒...")
    time.sleep(seconds)

def capture_window_screenshot(window_title="Godot", output_path=None):
    """截取指定窗口的截图 - 改进版"""
    print(f"尝试截取窗口: {window_title}")
    
    try:
        import mss
        import win32gui
        import win32ui
        from PIL import Image
        import win32con
        import win32api
        
        # 查找Godot窗口
        hwnd = win32gui.FindWindow(None, window_title)
        if not hwnd:
            print("未找到Godot窗口，尝试截取整个屏幕")
            hwnd = win32gui.GetDesktopWindow()
        
        if hwnd:
            # 获取窗口DC
            hwndDC = win32gui.GetWindowDC(hwnd)
            mfcDC = win32ui.CreateDCFromHandle(hwndDC)
            saveDC = mfcDC.CreateCompatibleDC()
            
            # 获取窗口大小
            left, top, right, bottom = win32gui.GetWindowRect(hwnd)
            width = right - left
            height = bottom - top
            
            print(f"窗口大小: {width}x{height}")
            
            # 创建位图
            saveBitMap = win32ui.CreateBitmap()
            saveBitMap.CreateCompatibleBitmap(mfcDC, width, height)
            saveDC.SelectObject(saveBitMap)
            
            # 截取屏幕
            result = saveDC.BitBlt((0, 0), (width, height), mfcDC, (0, 0), win32con.SRCCOPY)
            
            # 转换为PIL Image
            bmpinfo = saveBitMap.GetInfo()
            bmpstr = saveBitMap.GetBitmapBits(True)
            img = Image.frombuffer('RGB', (bmpinfo['bmWidth'], bmpinfo['bmHeight']), bmpstr, 'raw', 'BGRX', 0, 1)
            
            # 保存
            if output_path:
                img.save(output_path)
                print(f"截图已保存: {output_path}")
            
            # 清理
            win32gui.DeleteObject(saveBitMap.GetHandle())
            saveDC.DeleteDC()
            mfcDC.DeleteDC()
            win32gui.ReleaseDC(hwnd, hwndDC)
            
            return img
            
    except Exception as e:
        print(f"窗口截图失败: {e}")
    
    # 备用：使用mss
    try:
        with mss.mss() as sct:
            monitor = sct.monitors[1]  # 主显示器
            screenshot = sct.grab(monitor)
            img = Image.frombytes("RGB", screenshot.size, screenshot.bgra, "raw", "BGRX")
            if output_path:
                img.save(output_path)
                print(f"备用截图已保存: {output_path}")
            return img
    except Exception as e:
        print(f"备用截图也失败: {e}")
    
    return None

def send_key(key="space"):
    """发送按键到活动窗口"""
    print(f"发送按键: {key}")
    try:
        import pyautogui
        pyautogui.press(key)
        print("按键已发送")
    except Exception as e:
        print(f"发送按键失败: {e}")

def run_test(test_name="gameplay", delay_before_screenshot=8):
    """运行测试"""
    ensure_dir(SCREENSHOT_DIR)
    
    # 1. 启动Godot
    godot_proc = start_godot()
    
    # 2. 等待游戏加载
    print("等待游戏加载 " + str(delay_before_screenshot) + "秒...")
    time.sleep(delay_before_screenshot)
    
    # 3. 激活Godot窗口
    activate_window("Godot")
    time.sleep(1)
    
    # 4. 发送按键（模拟玩家）
    send_key("space")
    time.sleep(1)
    
    # 5. 截图
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    screenshot_path = os.path.join(SCREENSHOT_DIR, f"{test_name}_{timestamp}.png")
    capture_window_screenshot("Godot", screenshot_path)
    
    # 6. 关闭Godot
    print("关闭Godot...")
    godot_proc.terminate()
    try:
        godot_proc.wait(timeout=5)
    except:
        godot_proc.kill()
    
    return screenshot_path

if __name__ == "__main__":
    # 修复Windows编码
    import sys
    sys.stdout.reconfigure(encoding='utf-8')
    
    print("=" * 50)
    print("本地Godot自动化截图测试")
    print("=" * 50)
    
    # 检查依赖
    try:
        import mss
        print("✓ mss 已安装")
    except ImportError:
        print("✗ 需要安装 mss: pip install mss")
        sys.exit(1)
    
    # 运行测试
    result = run_test("gameplay", delay_before_screenshot=3)
    print(f"\n测试完成! 截图: {result}")
