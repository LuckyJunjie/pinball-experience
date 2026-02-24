# GDSnap Integration Guide

**基于:** fuyuan-game-development-flow 测试体系  
**工具:** GDSnap + GdUnit4  
**项目:** pinball-experience

---

## 安装状态

| 工具 | 状态 | 位置 |
|------|------|------|
| GUT | ✅ 已安装 | addons/gut/ |
| GdUnit4 | ⚠️ 插件损坏 | addons/gdunit4/ |
| GDSnap | ✅ 已安装 | addons/gdsnap/ |

---

## 使用 GDSnap 进行截图测试

### 1. 启用 GDSnap 插件

在 `project.godot` 中添加：
```gdscript
[plugin]

gdsnap="res://addons/gdsnap/plugin.gd"
```

### 2. 截图测试脚本

```gdscript
# test/integration/test_screenshot.gd
extends SceneTree

var screenshot_dir = "res://test/screenshot/"

func _initialize():
    await take_screenshots()
    quit()

func take_screenshots():
    print("===== 截图测试 =====")
    
    # 加载主场景
    var main = load("res://scenes/Main.tscn").instantiate()
    root.add_child(main)
    await process_frame
    
    # 截取屏幕
    var viewport = get_viewport()
    var image = viewport.get_texture().get_image()
    
    # 保存截图
    var dir = DirAccess.open(screenshot_dir)
    if dir:
        image.save_png(screenshot_dir + "current/main_scene.png")
        print("✓ 截图已保存: current/main_scene.png")
    
    main.free()
```

---

## GdUnit4 修复

GdUnit4 插件损坏，需要重新安装：

1. 从 Godot AssetLib 下载 GdUnit4
2. 解压到 `res://addons/gdunit4/`
3. 确保所有 .gd 文件完整

---

## 运行测试

```bash
# 运行基础测试
godot4.5.1 --headless --quit-after 3 -s test/run_tests.gd

# 运行截图测试
godot4.5.1 --headless --quit-after 5 -s test/integration/test_screenshot.gd
```

---

*更新: 2026-02-24*
