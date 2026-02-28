## Godot 自动化截图方案

### 方案 1: 代码截图 (推荐)

在 Godot 项目中集成截图代码，监听游戏事件自动截图：

```gdscript
# screenshot_capture.gd
extends Node

signal screenshot_captured(path: String)

@export var screenshot_dir: String = "user://screenshots/"
@export var capture_on_launch: bool = true
@export var capture_on_drain: bool = true

func _ready():
    # 确保截图目录存在
    DirAccess.make_dir_recursive_absolute(screenshot_dir)
    
    # 连接游戏事件
    if capture_on_launch:
        GameManager.game_started.connect(_on_game_started)
    if capture_on_drain:
        GameManager.round_lost.connect(_on_round_lost)

func _on_game_started():
    await get_tree().create_timer(0.5).timeout
    capture_screenshot("game_start")

func _on_round_lost(final_score: int, multiplier: int):
    await get_tree().create_timer(0.2).timeout
    capture_screenshot("drain")

func capture_screenshot(prefix: String = "screenshot"):
    var viewport = get_viewport()
    if viewport:
        var image = viewport.get_texture().get_image()
        if image:
            var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
            var filename = "%s_%s.png" % [prefix, timestamp]
            var path = screenshot_dir + filename
            image.save_png(path)
            print("截图已保存: ", path)
            screenshot_captured.emit(path)
```

### 方案 2: Xvfb + Godot (CI/树莓派)

```bash
# 安装 Xvfb
sudo apt-get install -y xvfb

# 运行 Godot 并截图
xvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" \
    godot --headless --path . --script test/auto_screenshot.gd
```

### 方案 3: 命令行参数触发

在 `project.godot` 中添加：

```ini
[application]

run/main_scene="res://scenes/Main.tscn"

[custom_args]

--screenshot="launch"  # launch, drain, all
```

在 Main.gd 中解析参数：

```gdscript
func _ready():
    var args = OS.get_cmdline_args()
    for arg in args:
        if arg.begins_with("--screenshot="):
            var mode = arg.replace("--screenshot=", "")
            setup_screenshot_mode(mode)

func setup_screenshot_mode(mode: String):
    match mode:
        "launch":
            GameManager.game_started.connect(capture_screenshot)
        "drain":
            GameManager.round_lost.connect(func(_, _): capture_screenshot())
        "all":
            GameManager.game_started.connect(capture_screenshot)
            GameManager.round_lost.connect(func(_, _): capture_screenshot())
```

### 自动化测试脚本

```gdscript
# test/automated_screenshot_test.gd
extends SceneTree

var test_results = []
var screenshot_base = "user://test_screenshots/"

func _initialize():
    print("===== 自动化截图测试 =====")
    
    # 确保目录存在
    DirAccess.make_dir_recursive_absolute(screenshot_base)
    
    # 加载主场景
    var main = load("res://scenes/Main.tscn").instantiate()
    root.add_child(main)
    
    # 等待初始化
    await process_frame
    await process_frame
    await create_timer(1.0).timeout
    
    # 测试场景 1: 游戏开始
    await test_game_start(main)
    
    # 测试场景 2: 发射球
    await test_launch_ball(main)
    
    # 测试场景 3: 球掉落
    await test_ball_drain(main)
    
    # 保存测试结果
    save_test_report()
    
    main.free()
    await create_timer(0.5).timeout
    quit()

func test_game_start(main: Node):
    print("\n--- 测试: 游戏开始 ---")
    await create_timer(0.5).timeout
    capture("game_start")
    test_results.append({"test": "game_start", "status": "pass"})

func test_launch_ball(main: Node):
    print("\n--- 测试: 发射球 ---")
    # 模拟发射
    var launcher = main.get_node_or_null("Launcher")
    if launcher and launcher.has_method("launch_ball"):
        launcher.launch_ball()
    await create_timer(1.0).timeout
    capture("ball_launched")
    test_results.append({"test": "ball_launch", "status": "pass"})

func test_ball_drain(main: Node):
    print("\n--- 测试: 球掉落 ---")
    # 等待球掉落或模拟
    await create_timer(3.0).timeout
    capture("ball_drain")
    test_results.append({"test": "ball_drain", "status": "pass"})

func capture(prefix: String):
    var viewport = get_viewport()
    if viewport:
        var tex = viewport.get_texture()
        if tex:
            var img = tex.get_image()
            if img:
                var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
                var path = screenshot_base + prefix + "_" + timestamp + ".png"
                img.save_png(path)
                print("✓ 截图: " + path)

func save_test_report():
    var report = JSON.stringify(test_results, "  ")
    var file = FileAccess.open("user://test_report.json", FileAccess.WRITE)
    if file:
        file.store_string(report)
        file.close()
        print("\n✓ 测试报告已保存")
```

### CI 集成

```yaml
# .github/workflows/screenshot-test.yml
name: Screenshot Tests
runs-on: ubuntu-latest
steps:
  - uses: actions/checkout@v4
  
  - name: Setup Xvfb
    run: sudo apt-get install -y xvfb
  
  - name: Setup Godot
    run: |
      wget -q https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_linux.x86_64.zip
      unzip -q Godot_v4.5.1-stable_linux.x86_64.zip
      chmod +x Godot_v4.5.1-stable_linux.x86_64
  
  - name: Run Screenshot Tests
    run: |
      xvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" \
        ./Godot_v4.5.1-stable_linux.x86_64 --headless --path . \
        --script test/automated_screenshot_test.gd
  
  - name: Upload Screenshots
    uses: actions/upload-artifact@v4
    with:
      name: screenshots
      path: |
        test_screenshots/
        test_report.json
```
