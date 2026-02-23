# 控制台测试用例 - pinball-experience

**Phase:** 0.1-0.5  
**目标:** 验证游戏各功能模块正常工作

---

## 日志格式规范

```
[时间戳] [级别] [模块名]: 消息内容
```

级别: DEBUG | INFO | WARN | ERROR

---

## 0.1 发射器 + 挡板

### TC-0.1.1 游戏启动
```
[INFO] GameManager: 游戏初始化完成
[INFO] Main: 场景加载完成
[INFO] Launcher: 发射器就绪
[INFO] Flipper: 左挡板已注册
[INFO] Flipper: 右挡板已注册
```

### TC-0.1.2 发射球
```
[INFO] Launcher: 发射请求
[INFO] Ball: 球已生成 (位置: 650, 450)
[INFO] Ball: 球已发射 (速度: -300, -400)
[DEBUG] Physics: 球进入物理模拟
```

### TC-0.1.3 左挡板激活
```
[INFO] Flipper: 左挡板按下
[DEBUG] Flipper: 旋转角度从 0° 到 -45°
[DEBUG] Physics: 挡板碰撞体激活
```

### TC-0.1.4 右挡板激活
```
[INFO] Flipper: 右挡板按下
[DEBUG] Flipper: 旋转角度从 0° 到 45°
[DEBUG] Physics: 挡板碰撞体激活
```

---

## 0.2 排水口

### TC-0.2.1 球掉入排水口
```
[INFO] Drain: 球进入排水口区域
[INFO] Drain: 球已移除
[DEBUG] GameManager: 球数 = 0
[INFO] GameManager: 触发回合结束
```

### TC-0.2.2 回合转换
```
[INFO] GameManager: 回合结束
[INFO] GameManager: 回合分数: {score}, 倍率: {multiplier}
[INFO] GameManager: 总分更新: {total_score}
[INFO] GameManager: 剩余回合: {rounds}
[INFO] Launcher: 生成新球
```

---

## 0.3 墙壁和边界

### TC-0.3.1 球碰墙
```
[DEBUG] Physics: 球碰撞 - WallLeft
[DEBUG] Physics: 反弹角度计算完成
[INFO] Ball: 碰撞反弹
```

---

## 0.4 障碍物 + 计分

### TC-0.4.1 击中障碍物
```
[INFO] Obstacle: 球撞击 {obstacle_name}
[INFO] GameManager: 得分 +{points} (来源: {obstacle_name})
[DEBUG] GameManager: 当前回合分数: {round_score}
[INFO] UI: 分数更新
```

### TC-0.4.2 得分变化
```
[INFO] GameManager: 得分变化
[INFO] UI: 分数显示更新为 {score}
```

---

## 0.5 回合 + 游戏结束

### TC-0.5.1 游戏开始
```
[INFO] GameManager: 游戏开始
[INFO] GameManager: 初始回合: 3
[INFO] GameManager: 初始分数: 0
[INFO] GameManager: 初始倍率: 1x
[INFO] Launcher: 发射器就绪
[INFO] Ball: 生成球 #1
```

### TC-0.5.2 第一次球掉出 (回合2)
```
[INFO] Drain: 球已移除
[INFO] GameManager: 回合 1 结束
[INFO] GameManager: 回合分数: {score} × {multiplier} = {total}
[INFO] GameManager: 更新总分: {total_score}
[INFO] GameManager: 进入回合 2/3
[INFO] Launcher: 生成新球
```

### TC-0.5.3 第二次球掉出 (回合1)
```
[INFO] Drain: 球已移除
[INFO] GameManager: 回合 2 结束
[INFO] GameManager: 回合分数: {score} × {multiplier} = {total}
[INFO] GameManager: 更新总分: {total_score}
[INFO] GameManager: 进入回合 3/3
[INFO] Launcher: 生成新球
```

### TC-0.5.4 游戏结束
```
[INFO] Drain: 球已移除
[INFO] GameManager: 回合 3 结束
[INFO] GameManager: 回合分数: {score} × {multiplier} = {total}
[INFO] GameManager: 更新总分: {total_score}
[INFO] GameManager: 游戏结束!
[INFO] GameManager: 最终分数: {final_score}
[INFO] UI: 显示游戏结束界面
```

### TC-0.5.5 重玩
```
[INFO] UI: 用户点击重新开始
[INFO] GameManager: 重置游戏状态
[INFO] GameManager: 游戏开始
[INFO] GameManager: 初始回合: 3
[INFO] GameManager: 初始分数: 0
[INFO] UI: 隐藏游戏结束界面
```

---

## 错误情况

### ER-01 球未生成
```
[ERROR] Launcher: 球生成失败 - ball_scene 为空
[ERROR] Launcher: 球生成失败 - balls_container 为空
```

### ER-02 得分失败
```
[WARN] GameManager: 得分失败 - 游戏状态不是 playing
[ERROR] GameManager: add_score 异常: {error_message}
```

### ER-03 场景加载失败
```
[ERROR] Main: 场景加载失败 - {resource_path}
[ERROR] Main: 缺少必需节点: {node_name}
```

---

## 运行命令

```bash
# 运行游戏并捕获日志
godot --headless --path . 2>&1 | tee pinball_test.log

# 分析日志
grep -E "\[INFO\]|\[WARN\]|\[ERROR\]" pinball_test.log
```
