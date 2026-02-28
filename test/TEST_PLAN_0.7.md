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
