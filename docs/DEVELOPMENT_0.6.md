# 0.6 障碍物区域开发计划

## 目标
在 pinball-experience 中实现 0.6 障碍物区域

## 区域划分 (基于 GDD.md)

### 1. Android Acres (左侧)
- 位置: x < 200
- 障碍物: Android bumpers, Spaceship

### 2. Dino Desert (发射器附近)
- 位置: 发射器右侧
- 障碍物: Chrome Dino, Slingshots

### 3. Flutter Forest (右上)
- 位置: x > 500, y < 200
- 障碍物: Dash bumpers

### 4. Sparky Scorch (左上)
- 位置: x < 200, y < 200
- 障碍物: Sparky bumpers

## 实现任务

1. [ ] 创建区域节点结构
2. [ ] 实现 Android 障碍物
3. [ ] 实现 Dino 障碍物  
4. [ ] 实现 Forest 障碍物
5. [ ] 实现 Sparky 障碍物
6. [ ] 添加测试
7. [ ] 截图验证
