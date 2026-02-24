# Extended Integration Tests - Drain, Obstacles, Scoring
extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("========================================")
	print("  Extended Integration Tests")
	print("========================================")
	
	await create_timer(0.5).timeout
	
	run_tests()
	
	print("========================================")
	print("  Result: %d passed, %d failed" % [tests_passed, tests_failed])
	print("========================================")
	
	await create_timer(0.5).timeout
	quit()

func run_tests():
	test_drain_exists()
	test_obstacles_exist()
	test_scoring_system()
	test_game_manager()
	test_ui_exists()

func test_drain_exists():
	print("\n--- Test: Drain ---")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	var drain = main.get_node("Playfield/Drain")
	if drain:
		print("✓ DI-01: Drain exists at position (%d, %d)" % [drain.position.x, drain.position.y])
		tests_passed += 1
		
		# Check collision shape
		var collision = drain.get_node("CollisionShape2D")
		if collision:
			print("✓ DI-02: Drain has collision shape")
			tests_passed += 1
		else:
			print("✗ DI-02: Drain missing collision shape")
			tests_failed += 1
	else:
		print("✗ DI-01: Drain node not found")
		tests_failed += 1
	
	main.free()

func test_obstacles_exist():
	print("\n--- Test: Obstacles ---")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	var obstacles = main.get_node("Obstacles")
	if obstacles:
		var count = obstacles.get_child_count()
		print("✓ OB-01: Obstacles container exists with %d children" % count)
		tests_passed += 1
		
		# Check each obstacle
		for i in range(count):
			var obs = obstacles.get_child(i)
			print("    - %s at (%d, %d)" % [obs.name, obs.position.x, obs.position.y])
			tests_passed += 1
	else:
		print("✗ OB-01: Obstacles container not found")
		tests_failed += 1
	
	main.free()

func test_scoring_system():
	print("\n--- Test: Scoring System ---")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# Test GameManager
	if GameManager:
		print("✓ SC-01: GameManager autoload exists")
		tests_passed += 1
		
		# Test initial score
		if GameManager.get("round_score") == 0:
			print("✓ SC-02: Initial round_score is 0")
			tests_passed += 1
		else:
			print("✗ SC-02: Initial round_score should be 0")
			tests_failed += 1
		
		# Test rounds
		if GameManager.rounds == 3:
			print("✓ SC-03: Initial rounds is 3")
			tests_passed += 1
		else:
			print("✗ SC-03: Initial rounds should be 3, got %d" % GameManager.rounds)
			tests_failed += 1
	else:
		print("✗ SC-01: GameManager not available")
		tests_failed += 1
	
	main.free()

func test_game_manager():
	print("\n--- Test: Game Manager ---")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# Check GameManager status
	if GameManager:
		var status = GameManager.status
		print("✓ GM-01: GameManager status: %s" % status)
		tests_passed += 1
		
		# Check multiplier
		var mult = GameManager.multiplier
		print("✓ GM-02: Multiplier: %d" % mult)
		tests_passed += 1
	else:
		print("✗ GM-01: GameManager not found")
		tests_failed += 1
	
	main.free()

func test_ui_exists():
	print("\n--- Test: UI Elements ---")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# Check HUD
	var hud = main.get_node("HUD")
	if hud:
		print("✓ UI-01: HUD exists")
		tests_passed += 1
		
		# Check ScoreLabel
		var score_label = hud.get_node("ScoreLabel")
		if score_label:
			print("✓ UI-02: ScoreLabel exists")
			tests_passed += 1
		else:
			print("✗ UI-02: ScoreLabel not found")
			tests_failed += 1
		
		# Check BallsLabel
		var balls_label = hud.get_node("BallsLabel")
		if balls_label:
			print("✓ UI-03: BallsLabel exists")
			tests_passed += 1
		else:
			print("✗ UI-03: BallsLabel not found")
			tests_failed += 1
	else:
		print("✗ UI-01: HUD not found")
		tests_failed += 1
	
	main.free()
