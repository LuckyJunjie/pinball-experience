# Godot MCP Server 方案

## 概述

创建一个MCP (Model Context Protocol) 服务器，让AI可以通过标准化协议控制Godot引擎进行自动化测试和截图。

## 方案设计

### 架构

```
AI Model (OpenClaw/MiniMax)
    |
    v
MCP Client (mcporter)
    |
    v
Godot MCP Server (本地HTTP/StdIO)
    |
    v
Godot Engine (图形界面)
```

### 实现方式

#### 方式1: HTTP服务器 (推荐)

```python
# godot_mcp_server.py
from flask import Flask, request, jsonify
import subprocess
import threading

app = Flask(__name__)

# MCP协议格式
@app.route('/mcp', methods=['POST'])
def mcp_handler():
    """处理MCP请求"""
    data = request.json
    method = data.get('method')
    params = data.get('params', {})
    
    if method == 'tools/list':
        return jsonify({
            'tools': [
                {'name': 'godot_run', 'description': '运行Godot项目'},
                {'name': 'godot_screenshot', 'description': '截取游戏画面'},
                {'name': 'godot_send_input', 'description': '发送按键输入'},
            ]
        })
    
    elif method == 'tools/call':
        tool = params.get('tool')
        args = params.get('arguments', {})
        
        if tool == 'godot_run':
            return godot_run(args)
        elif tool == 'godot_screenshot':
            return godot_screenshot(args)
        elif tool == 'godot_send_input':
            return godot_send_input(args)
    
    return jsonify({'error': 'Unknown method'})

def godot_run(args):
    """启动Godot"""
    # 启动Godot进程
    return {'result': 'started'}

def godot_screenshot(args):
    """截图"""
    # 调用截图脚本
    return {'result': 'screenshot saved'}

def godot_send_input(args):
    """发送输入"""
    # 模拟按键
    return {'result': 'input sent'}

if __name__ == '__main__':
    app.run(port=8765)
```

#### 方式2: 使用OpenClaw Godot技能

OpenClaw已有godot-plugin技能，可以直接控制Godot：

```bash
# 通过OpenClaw调用Godot
godot.execute --path pinball-experience --screenshot
```

#### 方式3: Godot内置TCP服务器

```gdscript
# 在Godot项目中添加TCP服务器
extends Node

var server = TCPServer.new()
var clients = []

func _ready():
    server.listen(8766)
    set_process(true)

func _process(delta):
    if server.is_connection_available():
        var client = server.take_connection()
        clients.append(client)
    
    for client in clients:
        if client.get_available_bytes() > 0:
            var data = client.get_string()
            handle_command(data)

func handle_command(cmd: String):
    match cmd:
        "screenshot":
            take_screenshot()
        "quit":
            get_tree().quit()
```

## Windows可行方案

### 方案A: 本地桌面运行 (推荐)

在MASTER Jay的本地桌面运行脚本:
1. 启动Godot GUI
2. Python脚本控制窗口并截图
3. 通过文件共享/SMB传输截图到服务器

### 方案B: Windows RDP/VNC

使用Windows远程桌面:
1. 通过RDP连接运行Godot
2. 截取远程桌面画面

### 方案C: WSL + Xvfb

在WSL中运行Linux版Godot:
```bash
# WSL中安装
sudo apt install xvfb
xvfb-run godot
```

## 结论

**Windows上最可行的方案:**
1. **本地桌面脚本** - MASTER Jay手动运行
2. **定时任务** - 通过Windows任务计划程序
3. **GitHub Actions** - Linux CI环境（已有Xvfb）

MCP服务器需要额外开发，但核心问题是Windows缺少图形界面支持。
