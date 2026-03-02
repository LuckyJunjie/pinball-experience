<<<<<<< HEAD
# Multiplier 0.7 - 测试计划

## 需求分析

### 0.7 Multiplier 功能需求

| 需求项 | 说明 |
|--------|------|
| 倍率范围 | 1-6 |
| 触发条件 | 每5次触发增加倍率 |
| 重置条件 | 回合结束时重置为1 |
| 得分计算 | totalScore += roundScore × multiplier |
| UI显示 | 显示当前倍率 |

---

## 4层测试策略

### Layer 1: 单元测试

```gdscript
func test_initial_multiplier():
    assert_eq(multiplier.current_multiplier, 1)

func test_increase_multiplier():
    multiplier.increase_multiplier()
    assert_eq(multiplier.current_multiplier, 2)

func test_max_multiplier():
    for i in range(6):
        multiplier.increase_multiplier()
    assert_eq(multiplier.current_multiplier, 6)

func test_reset():
    multiplier.increase_multiplier()
    multiplier.reset()
    assert_eq(multiplier.current_multiplier, 1)
```

### Layer 2: 集成测试

```gdscript
func test_trigger_increases():
    for i in range(5):
        multiplier.add_trigger()
    assert_eq(multiplier.current_multiplier, 2)

func test_score_application():
    multiplier.current_multiplier = 3
    var result = multiplier.apply_to_score(1000)
    assert_eq(result, 3000)
```

### Layer 3: 截图测试

- 验证倍率UI显示正确

### Layer 4: E2E测试

- 完整回合流程中的倍率应用

---

## 测试用例矩阵

| ID | 测试名称 | 层级 |
|----|----------|------|
| UT-0.7-01 | 初始倍率1 | 单元 |
| UT-0.7-02 | 增加倍率 | 单元 |
| UT-0.7-03 | 达到上限6 | 单元 |
| UT-0.7-04 | 重置 | 单元 |
| IT-0.7-01 | 5次触发增加 | 集成 |
| IT-0.7-02 | 得分计算 | 集成 |
| IT-0.7-03 | 信号发射 | 集成 |
| SS-0.7-01 | UI显示 | 截图 |
| E2E-0.7-01 | 回合流程 | E2E |
=======
# Pinball-Experience Test Plan 0.7 - Multiplier

**Version:** 0.7  
**Date:** 2026-02-28  
**Feature:** Multiplier (倍数)  
**Project:** pinball-experience

---

## 功能描述

- **Multiplier:** 倍数值为 1-6
- **触发条件:** 每击中5次目标，倍数+1
- **重置:** 回合结束时重置为1
- **应用:** 总分 = roundScore × multiplier

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
| 0.7.1 | Multiplier 初始值为1 | GameManager.multiplier == 1 |
| 0.7.2 | increase_multiplier 方法存在 | 方法存在 |
| 0.7.3 | Multiplier 最大为6 | 超过6时保持6 |

### 第二层: 集成测试

| ID | 测试用例 | 预期结果 |
|----|----------|----------|
| 0.7.4 | 击中5次倍数+1 | multiplier: 1→2 |
| 0.7.5 | 击中10次倍数+2 | multiplier: 2→3 |
| 0.7.6 | 倍数最大为6 | 30次后保持6 |
| 0.7.7 | 回合结束重置 | round_lost后multiplier=1 |
| 0.7.8 | 计分包含倍数 | totalScore += roundScore × multiplier |

### 第三层: 截图测试

| ID | 测试用例 | 预期结果 |
|----|----------|----------|
| 0.7.9 | HUD显示倍数 | 显示 "x2" 等 |

---

## 运行测试

```bash
# 运行 0.7 测试
DISPLAY=:99 godot --headless --path . -s test/test_multiplier.gd
```
>>>>>>> 705116bfd71db35fc81043d20a98e382b39bc825
