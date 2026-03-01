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
