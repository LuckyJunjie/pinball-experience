# Godot Xvfb 自动化截图方案

## 概述

在Linux环境（如树莓派）上，使用Xvfb（虚拟帧缓冲）运行Godot并实现自动化截图。

## Xvfb 方案

### 安装Xvfb

```bash
# Debian/Ubuntu/Raspbian
sudo apt update
sudo apt install xvfb

# 检查安装
xvfb-run --version
```

### 基本用法

```bash
# 使用Xvfb运行Godot（默认分辨率）
xvfb-run -a godot --path /path/to/project --headless

# 指定分辨率
xvfb-run -a -s "-screen 0 1024x768x24" godot --path .
```

### 自动化截图

```bash
# 运行游戏并截图
xvfb-run -a godot --path . --screenshot

# 在特定事件截图
xvfb-run -a godot --path . --screenshot-on=ball_launch
```

## 树莓派部署脚本

### 1. 安装依赖

```bash
#!/bin/bash
# install_godot_xvfb.sh

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Xvfb
sudo apt install -y xvfb

# 下载Godot (ARM64版本)
wget -O godot.zip https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_linux.arm64.zip
unzip godot.zip
chmod +x Godot_v4.5.1-stable_linux.arm64
mv Godot_v4.5.1-stable_linux.arm64 /usr/local/bin/godot

echo "安装完成!"
```

### 2. 运行脚本

```bash
# 自动截图脚本
#!/bin/bash
# run_godot_xvfb.sh

export DISPLAY=:99

# 启动Xvfb
Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &

# 等待Xvfb启动
sleep 2

# 运行Godot截图
godot --path /home/pi/pinball-experience --screenshot

# 等待截图完成
sleep 3

# 关闭Xvfb
pkill Xvfb
```

## Windows WSL 方案

### 在WSL中运行Godot + Xvfb

```bash
# 安装WSL (如果未安装)
wsl --install

# 在Ubuntu WSL中安装xvfb
sudo apt install xvfb

# 运行
xvfb-run -a godot --path /mnt/c/path/to/project
```

## Docker 方案

### 创建Docker镜像

```dockerfile
# Dockerfile.godot-xvfb
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安装依赖
RUN apt update && apt install -y \
    xvfb \
    wget \
    unzip \
    libgl1-mesa-dri \
    libglib2.0-0 \
    libasound2 \
    libpulse0

# 下载Godot
RUN wget -O godot.zip https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_linux.x86_64.zip && \
    unzip godot.zip && \
    chmod +x Godot_v4.5.1-stable_linux.x86_64 && \
    mv Godot_v4.5.1-stable_linux.x86_64 /usr/local/bin/godot

WORKDIR /project

CMD ["xvfb-run", "-a", "godot", "--path", ".", "--headless"]
```

### 构建和运行

```bash
# 构建镜像
docker build -f Dockerfile.godot-xvfb -t godot-xvfb .

# 运行
docker run -v $(pwd):/project godot-xvfb --screenshot
```

## 自动化测试集成

### 在CI/CD中使用

```yaml
# .drone.yml (Linux Runner)
kind: pipeline
type: docker
name: godot-test

steps:
  - name: setup
    commands:
      - apt update && apt install -y xvfb
      - wget -O godot.zip https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_linux.x86_64.zip
      - unzip godot.zip && chmod +x Godot*

  - name: test
    commands:
      - xvfb-run -a ./Godot* --path . --screenshot-on=ball_launch

  - name: artifacts
    commands:
      - cp screenshots/*.png artifacts/
```

## 故障排查

### Xvfb启动失败

```bash
# 检查是否有其他X服务器在运行
ps aux | grep X

# 尝试不同显示编号
Xvfb :1 -screen 0 1024x768x24
export DISPLAY=:1
```

### Godot渲染问题

```bash
# 使用OpenGL ES
xvfb-run -a godot --rendering-method mobile --path .

# 或使用gl
xvfb-run -a godot --rendering-method gl_compatibility --path .
```

### 截图保存位置

Godot 4.x 截图保存在:
- Linux: `~/.local/share/godot/app_userdata/<project>/screenshots/`
- Windows: `%APPDATA%\Godot\app_userdata\<project>\screenshots\`

## 完整自动化流程

```python
# 自动测试流程
def automated_godot_test():
    """完整的自动化测试流程"""
    
    # 1. 游戏开始截图
    run_godot("--screenshot")
    
    # 2. 模拟按键发射球
    simulate_key("space")
    time.sleep(1)
    
    # 3. 等待球掉落
    time.sleep(5)
    
    # 4. 获取截图
    screenshots = get_screenshots()
    
    return screenshots
```

## 总结

| 方案 | 平台 | 复杂度 | 性能 |
|------|------|--------|------|
| Xvfb + Godot | Linux/树莓派 | 中 | 好 |
| WSL + Xvfb | Windows | 低 | 好 |
| Docker | 跨平台 | 中 | 中 |
| 代码截图 | 全平台 | 低 | 好 |

推荐使用**代码截图方案**（已在项目中实现），配合Xvfb作为备选方案。
