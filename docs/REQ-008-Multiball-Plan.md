# REQ-008 Multiball 开发计划

**需求:** REQ-008 pinball 0.8 Multiball  
**项目:** pinball-experience  
**状态:** 45% in_progress  
**创建:** 2026-03-01

---

## 概述

Multiball 功能允许玩家在获得特定奖励 (googleWord 或 dashNest) 后额外获得一个奖励球 (bonus ball)。

### 触发条件 (来自 Requirements.md)

| Bonus ID | Trigger | Effect |
|----------|---------|--------|
| googleWord | 所有 Google 字母点亮 | Bonus recorded; bonus ball spawn after 5s |
| dashNest | 所有 Dash bumpers 点亮 | Bonus recorded; bonus ball spawn after 5s |

---

## 当前实现状态

### ✅ 已完成

1. **GameManager.gd** - bonus ball 逻辑框架
   - `bonus_ball_timer` (5秒延迟)
   - `bonus_ball_requested` 信号
   - `active_bonus_balls` 计数器
   - `_schedule_bonus_ball()` 和 `_on_bonus_ball_timer_timeout()`

2. **Main.gd** - bonus ball 生成
   - `_on_bonus_ball_requested()` 实现了球生成和发射

3. **资源文件** - `assets/sprites/multiball/`
   - `dimmed.png` - 未激活状态
   - `lit.png` - 激活状态

### 🔄 待实现

1. **MultiballIndicator 场景** - 4个指示灯显示已获得/激活的 bonus balls
2. **BonusBall 增强** - 特殊外观和行为
3. **Drain 多球处理** - 修复: 所有球都掉落才算回合结束
4. **UI HUD 增强** - 显示 active_bonus_balls 数量
5. **测试** - 单元测试和集成测试

---

## 开发任务

### Task 1: MultiballIndicator 组件

**文件:** `scenes/MultiballIndicator.tscn`, `scripts/MultiballIndicator.gd`

```gdscript
# 功能:
# - 显示4个指示灯位置
# - 根据 active_bonus_balls 点亮对应数量的灯
# - 动画效果 (闪烁/渐变)
```

**UI 位置:** Playfield 顶部 Backbox 区域

### Task 2: BonusBall 增强

**文件:** `scenes/BonusBall.tscn` (可继承自 Ball.tscn)

```gdscript
# 功能:
# - 特殊外观 (金色球)
# - 可能增加一些特殊行为 (如更短的弹跳)
```

### Task 3: Drain 多球逻辑修复

**文件:** `scripts/Drain.gd`

**问题:** 当前逻辑是每掉一个球就触发 `on_ball_removed()`，但应该等待所有球都掉落才算回合结束。

```gdscript
func _on_ball_removed() -> void:
    # 修改前: 每掉一个球就检查
    # 修改后: 等待所有球都掉落
    
    # 使用 GameManager.get_ball_count() 判断
    if GameManager.get_ball_count() <= 0:
        GameManager.on_round_lost()
```

### Task 4: UI HUD 增强

**文件:** `scripts/UI.gd`

```gdscript
# 添加显示:
# - "Bonus Balls: X" 当 active_bonus_balls > 0 时
```

### Task 5: Main.gd 集成

**文件:** `scripts/Main.gd`

```gdscript
# 连接 MultiballIndicator
# 更新 UI 显示
```

---

## 测试计划

### 单元测试

- `test_multiball_indicator.gd` - 指示灯状态测试

### 集成测试

- `test_multiball_e2e.gd` - 完整 multiball 流程:
  1. 触发 googleWord/dashNest bonus
  2. 等待 5 秒
  3. 验证 bonus ball 生成
  4. 验证多球同时存在
  5. 验证所有球掉落才算回合结束

---

## 验收标准

| 标准 | 描述 |
|------|------|
| AC-1 | 触发 googleWord/dashNest 后 5 秒生成 bonus ball |
| AC-2 | MultiballIndicator 显示当前激活的 bonus balls (最多4个) |
| AC-3 | 多个球可以同时存在于场地上 |
| AC-4 | 只有当所有球都掉落时才触发回合结束 |
| AC-5 | UI 显示当前 active_bonus_balls 数量 |

---

## 预计工作量

| 任务 | 预计时间 |
|------|----------|
| MultiballIndicator | 1-2 小时 |
| BonusBall 增强 | 30 分钟 |
| Drain 逻辑修复 | 30 分钟 |
| UI 增强 | 30 分钟 |
| 测试 | 1-2 小时 |
| **总计** | **4-6 小时** |

---

## 依赖

- REQ-006 Skill Shot (需完成以测试 googleWord 触发)
- REQ-007 Multiplier (已完成基础)

---

*此文档由 subagent 创建用于协调 REQ-008 开发*
