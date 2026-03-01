# Godot MCP Server - 自动化测试方案

## 概述

MCP (Model Context Protocol) 服务器，用于AI控制Godot引擎进行自动化测试。

## GDSnap 方案（已集成）

**项目已集成GDSnap插件**（位于 `addons/gdsnap`）

### 截图配置
- 截图目录: `res://screenshots/`
- 基准图: `res://screenshots/base/`
- 差异图: `res://screenshots/diff/`

### 使用方法

```gdscript
# 在测试脚本中使用GDSnap
extends GutTest

func test_example():
    await get_tree().process_frame
    var viewport = get_viewport()
    var image = viewport.get_texture().get_image()
    image.save_png("res://screenshots/base/test.png")
```

## Godot MCP Server 设计

### 方案1: HTTP API Server

```python
#!/usr/bin/env python3
"""
Godot MCP Server - HTTP API方式
让AI可以通过HTTP API控制Godot
"""

from flask import Flask, request, jsonify
import subprocess
import os
import time

app = Flask(__name__)

GODOT_PATH = r"D:\game_development\godot\Godot_v4.5.1-stable_win64.exe"
PROJECT_PATH = r"C:\Users\panju\.openclaw\workspace\pinball-experience"

# MCP工具定义
TOOLS = [
    {
        "name": "godot_start",
        "description": "启动Godot项目",
        "inputSchema": {
            "type": "object",
            "properties": {
                "project": {"type": "string", "description": "项目路径"},
                "scene": {"type": "string", "description": "场景文件"}
            }
        }
    },
    {
        "name": "godot_screenshot",
        "description": "截取当前游戏画面",
        "inputSchema": {
            "type": "object",
            "properties": {
                "name": {"type": "string", "description": "截图名称"}
            }
        }
    },
    {
        "name": "godot_send_key",
        "description": "发送键盘按键",
        "inputSchema": {
            "type": "object",
            "properties": {
                "key": {"type": "string", "description": "按键名称(space, left, right等)"}
            }
        }
    }
]

@app.route('/mcp/tools', methods=['GET'])
def list_tools():
    return jsonify({"tools": TOOLS})

@app.route('/mcp/call', methods=['POST'])
def call_tool():
    data = request.json
    tool_name = data.get('tool')
    arguments = data.get('arguments', {})
    
    if tool_name == "godot_start":
        return godot_start(arguments)
    elif tool_name == "godot_screenshot":
        return godot_screenshot(arguments)
    elif tool_name == "godot_send_key":
        return godot_send_key(arguments)
    
    return jsonify({"error": "Unknown tool"})

def godot_start(args):
    project = args.get('project', PROJECT_PATH)
    scene = args.get('scene', 'res://scenes/Main.tscn')
    
    # 启动Godot
    proc = subprocess.Popen(
        [GODOT_PATH, "--path", project, "--scene", scene, "--quit-after", "30"],
        cwd=project
    )
    
    return jsonify({"result": "Godot started", "pid": proc.pid})

def godot_screenshot(args):
    name = args.get('name', 'screenshot')
    # 截图逻辑
    return jsonify({"result": f"Screenshot saved: {name.png}"})

def godot_send_key(args):
    key = args.get('key', 'space')
    # 发送按键逻辑
    return jsonify({"result": f"Key sent: {key}"})

if __name__ == '__main__':
    app.run(port=8765, debug=True)
```

### 方案2: StdIO方式 (更符合MCP规范)

```python
#!/usr/bin/env python3
"""
Godot MCP Server - StdIO方式
符合MCP协议的标准输入输出方式
"""

import sys
import json
import subprocess

def handle_request(request):
    method = request.get('method')
    params = request.get('params', {})
    
    if method == 'tools/list':
        return {
            "tools": [
                {"name": "godot_run", "description": "运行Godot"},
                {"name": "godot_screenshot", "description": "截图"},
            ]
        }
    
    elif method == 'tools/call':
        tool = params.get('tool')
        args = params.get('arguments', {})
        
        if tool == "godot_run":
            return run_godot(args)
        elif tool == "godot_screenshot":
            return take_screenshot(args)
    
    return {"error": "Unknown method"}

def run_godot(args):
    # 启动Godot进程
    return {"result": "started"}

def take_screenshot(args):
    # 截图
    return {"result": "screenshot taken"}

# MCP主循环
if __name__ == '__main__':
    while True:
        line = sys.stdin.readline()
        if not line:
            break
        
        request = json.loads(line)
        response = handle_request(request)
        
        sys.stdout.write(json.dumps(response) + '\n')
        sys.stdout.flush()
```

### 方案3: OpenClaw集成

```python
# openclaw_godot_mcp.py
# OpenClaw技能调用Godot MCP

async def godot_mcp_call(tool: str, args: dict):
    """通过MCP调用Godot"""
    result = await mcporter.call(f"godot.{tool}", **args)
    return result
```

## 结论

**推荐方案：**

1. **GDSnap** - 项目已集成，用于截图测试
2. **HTTP MCP Server** - 简单易实现
3. **GitHub Actions** - 最可靠的自动化测试（Linux + Xvfb）

**Windows问题：** 缺少图形界面是根本问题，MCP不能解决
