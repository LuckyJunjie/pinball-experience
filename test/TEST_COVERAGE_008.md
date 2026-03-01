# Multiball (REQ-008) - 测试覆盖文档

## REQ-008 验收标准

| | 描述 |
|------|------ 标准|
| AC-1 | 触发 googleWord/dashNest 后 5 秒生成 bonus ball |
| AC-2 | MultiballIndicator 显示当前激活的 bonus balls (最多4个) |
| AC-3 | 多个球可以同时存在于场地上 |
| AC-4 | 只有当所有球都掉落时才触发回合结束 |
| AC-5 | UI 显示当前 active_bonus_balls 数量 |

---

## 测试矩阵

### 单元测试 (Unit Tests)

| ID | 测试名称 | 测试内容 | 预期结果 | 状态 |
|----|----------|----------|----------|------|
| UT-008-01 | 初始状态 | active_bonus_balls 初始值 | 0 | ✅ |
| UT-008-02 | 延迟常量 | BONUS_BALL_DELAY | 5.0 秒 | ✅ |
| UT-008-03 | 方法存在 | add_bonus 方法 | 存在 | ✅ |
| UT-008-04 | bonus添加 | googleWord 添加到 history | 成功 | ✅ |
| UT-008-05 | 计时器 | bonus_ball_timer 创建 | 已创建 | ✅ |
| UT-008-06 | 信号存在 | bonus_ball_requested 信号 | 存在 | ✅ |
| UT-008-07 | 场景加载 | MultiballIndicator 场景 | 可加载 | ✅ |
| UT-008-08 | 指示灯 | 4个指示灯节点 | 存在 | ✅ |
| UT-008-09 | 更新方法 | _update_indicators 方法 | 存在 | ✅ |
| UT-008-10 | 纹理加载 | dimmed/lit 纹理 | 已预加载 | ✅ |
| UT-008-11 | 指示灯更新 | _update_indicators 调用 | 正常 | ✅ |
| UT-008-12 | Drain节点 | Drain 节点存在 | 存在 | ✅ |
| UT-008-13 | 球计数 | get_ball_count 方法 | 存在 | ✅ |
| UT-008-14 | 球移除 | on_ball_removed 方法 | 存在 | ✅ |
| UT-008-15 | 球生成 | 球生成功能 | 成功 | ✅ |

### 集成测试 (Integration Tests)

| ID | 测试名称 | 测试内容 | 预期结果 | AC覆盖 |
|----|----------|----------|----------|--------|
| IT-008-01 | Bonus生成延迟 | googleWord触发后5秒 | bonus ball生成 | AC-1 |
| IT-008-02 | active_balls更新 | bonus后计数器 | 已更新 | AC-1 |
| IT-008-03 | dashNest触发 | dashNest触发 | bonus ball生成 | AC-1 |
| IT-008-04 | 指示灯存在 | MultiballIndicator | 存在 | AC-2 |
| IT-008-05 | 单球指示 | 1个bonus时 | active=1 | AC-2 |
| IT-008-06 | 指示灯上限 | 6个bonus后 | active≤4 | AC-2 |
| IT-008-07 | 多球共存 | 1个bonus后 | ≥2个球 | AC-3 |
| IT-008-08 | 3球共存 | 2个bonus后 | ≥3个球 | AC-3 |
| IT-008-09 | 部分球掉落 | 部分球掉落后 | 不触发结束 | AC-4 |
| IT-008-10 | 全部球掉落 | 所有球掉落后 | 触发回合结束 | AC-4 |
| IT-008-11 | UI存在 | UI/Control | 存在 | AC-5 |
| IT-008-12 | Multiball UI | MultiballIndicator UI | 存在 | AC-5 |
| IT-008-13 | active追踪 | bonus后计数 | 正确追踪 | AC-5 |
| IT-008-14 | 更新方法 | _update_indicators | 存在 | AC-5 |

### E2E 测试 (End-to-End Tests)

| ID | 测试名称 | 测试内容 | 预期结果 | AC覆盖 |
|----|----------|----------|----------|--------|
| E2E-008-01 | 完整流程 | 发射→触发→等待→验证 | 完整流程成功 | AC-1,2,3 |
| E2E-008-02 | 多次Multiball | 3次bonus | 4个球同时存在 | AC-2,3 |
| E2E-008-03 | 游戏结束 | 所有球掉落后 | 触发game_over | AC-4 |

---

## 验收标准覆盖

| AC | 描述 | 单元测试 | 集成测试 | E2E测试 |
|----|------|----------|----------|---------|
| AC-1 | 5秒生成bonus ball | UT-008-02,05 | IT-008-01,02,03 | E2E-008-01 |
| AC-2 | MultiballIndicator显示 | UT-008-07,08,09,10 | IT-008-04,05,06 | E2E-008-02 |
| AC-3 | 多球共存 | UT-008-15 | IT-008-07,08 | E2E-008-01,02 |
| AC-4 | 全部掉落结束回合 | UT-008-13,14 | IT-008-09,10 | E2E-008-03 |
| AC-5 | UI显示active_bonus_balls | UT-008-11 | IT-008-11,12,13,14 | - |

---

## 测试文件

- `test/unit/test_multiball.gd` - 单元测试
- `test/integration/test_multiball.gd` - 集成测试
- `test/integration/test_multiball_e2e.gd` - E2E 测试

---

## 运行测试

```bash
# 单元测试
godot --headless --script test/unit/test_multiball.gd

# 集成测试
godot --headless --script test/integration/test_multiball.gd

# E2E 测试
godot --headless --script test/integration/test_multiball_e2e.gd

# 运行所有测试
godot --headless --script test/run_tests.gd
```

---

## 已知问题

1. **AC-4**: Drain.gd 当前实现是每掉一个球就调用 `on_ball_removed()`，需要修改为等待所有球都掉落
2. **AC-5**: UI.gd 尚未添加 active_bonus_balls 显示

---

*最后更新: 2026-03-01*
