extends GutTest
## Multiplier 集成测试

var multiplier: Multiplier = null
var game_manager: Node = null

func before_each():
	multiplier = Multiplier.new()
	add_child(multiplier)
	
	# 模拟GameManager
	game_manager = Node.new()
	game_manager.set_meta("class_name", "GameManager")
	add_child(game_manager)

# ============ GameManager集成测试 ============

func test_integration_with_game_manager():
	# 设置回合分数
	var round_score = 5000
	
	# 应用倍率
	var final_score = multiplier.apply_to_score(round_score)
	
	# 验证得分计算
	assert_eq(final_score, 5000, "初始倍率1时不增加")

func test_multiplier_affects_score():
	multiplier.current_multiplier = 4
	var round_score = 10000
	var total_score = multiplier.apply_to_score(round_score)
	assert_eq(total_score, 40000, "4倍率应该×4")

# ============ 回合流程集成测试 ============

func test_round_start_multiplier():
	# 新回合开始
	multiplier.reset()
	assert_eq(multiplier.current_multiplier, 1, "新回合应从倍率1开始")

func test_round_end_multiplier_application():
	# 设置回合分数和倍率
	multiplier.current_multiplier = 3
	var round_score = 2000
	
	# 计算最终得分
	var final = multiplier.apply_to_score(round_score)
	assert_eq(final, 6000, "回合得分应×倍率")

# ============ 多回合测试 ============

func test_multiple_rounds():
	var total = 0
	
	# 第1回合
	multiplier.current_multiplier = 2
	total += multiplier.apply_to_score(1000)
	multiplier.reset()
	
	# 第2回合
	multiplier.current_multiplier = 3
	total += multiplier.apply_to_score(1000)
	
	assert_eq(total, 5000, "两回合总分应为5000")

# ============ 边界测试 ============

func test_zero_score():
	multiplier.current_multiplier = 6
	var result = multiplier.apply_to_score(0)
	assert_eq(result, 0, "0分×任何倍率仍为0")

func test_max_score_with_max_multiplier():
	multiplier.current_multiplier = 6
	var result = multiplier.apply_to_score(999999)
	assert_eq(result, 5999994, "最大分数测试")
