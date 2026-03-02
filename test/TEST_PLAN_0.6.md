<<<<<<< HEAD
# Pinball 0.6 Skill Shot - 测试计划

## 需求分析

### 0.6 Skill Shot 功能需求

| 需求项 | 说明 |
|---------|------|
| 技能射击目标 | 发射后2-3秒内激活 |
| 得分 | 击中 → +1,000,000分 |
| 时间窗口 | 窗口期后击中 → 无奖励 |
| 反馈 | 击中时视觉/声音反馈 |
| 状态 | 激活 → 过期 |

---

## 4层测试策略

### Layer 1: 单元测试 (Unit Test)

```gdscript
# test_skill_shot.gd
extends GutTest

var skill_shot: SkillShot

func before_each():
    skill_shot = load("res://scenes/SkillShot.tscn").instantiate()

func test_skill_shot_initial_state():
    assert_eq(skill_shot.is_active, false)
    assert_eq(skill_shot.time_remaining, 0.0)

func test_skill_shot_activation():
    skill_shot.activate()
    assert_eq(skill_shot.is_active, true)
    assert_true(skill_shot.time_remaining > 0)

func test_skill_shot_timeout():
    skill_shot.activate()
    await get_tree().create_timer(3.5).timeout
    assert_eq(skill_shot.is_active, false)
```

### Layer 2: 集成测试 (Integration Test)

```gdscript
# test_skill_shot_integration.gd
extends GutTest

func test_skill_shot_score_integration():
    # 发射球
    launcher.spawn_ball()
    
    # 激活技能射击
    skill_shot.activate()
    
    # 等待球击中技能射击目标
    await get_tree().create_timer(1.0).timeout
    
    # 验证得分
    assert_eq(GameManager.round_score, 1000000)

func test_skill_shot_missed_window():
    launcher.spawn_ball()
    skill_shot.activate()
    
    # 等待窗口过期
    await get_tree().create_timer(3.5).timeout
    
    # 击中 - 不应该得分
    ball.global_position = skill_shot.global_position
    await get_tree().process_frame
    
    assert_eq(GameManager.round_score, 0)
```

### Layer 3: 截图测试 (Screenshot Test)

```gdscript
# test_skill_shot_screenshot.gd
extends GutTest

func test_skill_shot_visual_feedback():
    # 激活技能射击
    skill_shot.activate()
    
    # 等待球接近
    await get_tree().create_timer(1.0).timeout
    
    # 触发击中
    skill_shot.emit_signal("hit")
    
    # 截图验证视觉反馈
    var viewport = get_viewport()
    var image = viewport.get_texture().get_image()
    image.save_png("res://screenshots/test_skill_shot_hit.png")
    
    # 验证文件存在
    assert_true(FileAccess.file_exists("res://screenshots/test_skill_shot_hit.png"))
```

### Layer 4: E2E测试 (End-to-End)

```gdscript
# test_skill_shot_e2e.gd
extends GutTest

func test_full_gameplay_with_skill_shot():
    # 1. 开始游戏
    GameManager.start_game()
    assert_eq(GameManager.status, "playing")
    
    # 2. 发射球
    launcher.launch_ball()
    
    # 3. 等待技能射击窗口
    await get_tree().create_timer(1.0).timeout
    
    # 4. 击中技能射击 → +1M
    # (ball碰撞技能射击目标)
    await get_tree().create_timer(0.5).timeout
    assert_eq(GameManager.round_score, 1000000)
    
    # 5. 球掉落drain
    ball.global_position = drain.global_position
    await get_tree().process_frame
    
    # 6. 回合结束，验证得分累计
    assert_eq(GameManager.rounds, 2)
    
    # 7. 重复直到游戏结束
    # ... (完整流程)
```

---

## 测试用例矩阵

| 测试ID | 测试名称 | 层级 | 预期结果 |
|--------|----------|------|----------|
| UT-0.6-01 | 初始状态 | 单元 | is_active=false |
| UT-0.6-02 | 激活技能射击 | 单元 | is_active=true |
| UT-0.6-03 | 超时过期 | 单元 | is_active=false |
| IT-0.6-01 | 击中得分 | 集成 | +1,000,000分 |
| IT-0.6-02 | 窗口外击中 | 集成 | +0分 |
| IT-0.6-03 | 重复激活 | 集成 | 状态正确 |
| SS-0.6-01 | 激活视觉 | 截图 | 截图存在 |
| SS-0.6-02 | 击中视觉 | 截图 | 截图存在 |
| E2E-0.6-01 | 完整流程 | E2E | 游戏正常 |

---

## 实现检查清单

- [ ] SkillShot场景和脚本
- [ ] 激活/超时逻辑
- [ ] 得分奖励 (1M)
- [ ] 视觉反馈 (粒子/文字)
- [ ] 声音反馈
- [ ] GameManager集成
- [ ] 单元测试
- [ ] 集成测试
- [ ] 截图测试
- [ ] E2E测试
=======
# Pinball-Experience Test Plan 0.6 - Skill Shot

**Version:** 0.6  
**Date:** 2026-02-28  
**Feature:** Skill Shot  
**Project:** pinball-experience

---

## 功能描述

- **Skill Shot:** 目标区域在发射后 2-3 秒内 "active"
- 如果球在 active 期间击中 → 奖励 1,000,000 分
- 之后 inactive，直到下次发射

---

## 四层测试体系

| 层级 | 测试类型 | 工具 |
|------|----------|------|
| 第一层 | 单元测试 | GUT/GdUnit4 |
| 第二层 | 集成测试 | 内置脚本 |
| 第三层 | 截图测试 | GDSnap |
| 第四层 | 性能测试 | Profiler |

---

## 测试用例

### 第一层: 单元测试

| ID | 测试用例 | 预期结果 |
|----|----------|----------|
| 0.6.1 | SkillShot 节点存在 | 场景中有 SkillShot 节点 |
| 0.6.2 | SkillShot 位置正确 | 在发射路径上 |
| 0.6.3 | 积分常量正确 | SKILL_SHOT_POINTS = 1000000 |

### 第二层: 集成测试

| ID | 测试用例 | 预期结果 |
|----|----------|----------|
| 0.6.4 | 发射后激活 | 球发射后 skill_shot_active = true |
| 0.6.5 | 窗口期内击中 | 窗口期内击中 +1M 分 |
| 0.6.6 | 窗口期后无效 | 窗口期后击中不加分 |
| 0.6.7 | 窗口期超时 | 2-3秒后自动失效 |

### 第三层: 截图测试

| ID | 测试用例 | 预期结果 |
|----|----------|----------|
| 0.6.8 | 技能 shot 激活截图 | 显示激活状态 |
| 0.6.9 | 击中得分截图 | 显示 +1M 弹出 |

---

## 实现状态

| ID | 状态 | 说明 |
|----|------|------|
| 0.6.1 | ⚠️ 待实现 | 需创建 SkillShot 节点 |
| 0.6.2 | ⚠️ 待实现 | 需创建 SkillShot 节点 |
| 0.6.3 | ⚠️ 待实现 | 需实现 |
| 0.6.4 | ⚠️ 待实现 | 需实现 |
| 0.6.5 | ⚠️ 待实现 | 需实现 |
| 0.6.6 | ⚠️ 待实现 | 需实现 |
| 0.6.7 | ⚠️ 待实现 | 需实现 |
| 0.6.8 | ⚠️ 待实现 | 需实现 |
| 0.6.9 | ⚠️ 待实现 | 需实现 |

---

## 运行测试

```bash
# 运行 0.6 测试
DISPLAY=:99 godot --headless --path . -s test/test_skill_shot.gd
```
>>>>>>> 705116bfd71db35fc81043d20a98e382b39bc825
