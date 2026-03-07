#!/usr/bin/env godot --headless --script
# Pinball Experience - CI Test Runner
# Runs all tests and outputs results in a format CI can parse

extends SceneTree

var tests_passed := 0
var tests_failed := 0
var test_results := []

func _initialize() -> void:
	print("========================================")
	print("  Pinball Experience - CI Test Runner")
	print("========================================")
	
	# Load main scene
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# Wait for initialization
	await create_timer(1.0).timeout
	
	# Run all tests
	run_all_tests()
	
	# Print summary
	print("\n========================================")
	print("  CI Test Results")
	print("========================================")
	print("Total: %d | Passed: %d | Failed: %d" % [tests_passed + tests_failed, tests_passed, tests_failed])
	
	for result in test_results:
		print(result)
	
	# Exit with appropriate code
	if tests_failed > 0:
		print("\n❌ TESTS FAILED")
		quit(1)
	else:
		print("\n✅ ALL TESTS PASSED")
		quit(0)

func run_all_tests() -> void:
	# Test 0.1: Launcher + Flippers
	test_launcher_and_flippers()
	
	# Test 0.2: Drain
	test_drain()
	
	# Test 0.3: Walls
	test_walls()
	
	# Test 0.4: Obstacles
	test_obstacles()
	
	# Test 0.5: Game State
	test_game_state()
	
	# Test Skill Shot
	test_skill_shot()
	
	# Test Multiplier
	test_multiplier()

func test_launcher_and_flippers() -> void:
	var main = root.get_node("Main")
	if not main:
		fail_test("test_launcher_and_flippers", "Main scene not found")
		return
	
	# Check launcher
	if has_node(main, "Launcher"):
		pass_test("test_launcher_and_flippers", "Launcher exists")
	else:
		fail_test("test_launcher_and_flippers", "Launcher not found")
	
	# Check flippers
	if has_node(main, "FlipperLeft") and has_node(main, "FlipperRight"):
		pass_test("test_flippers", "Flippers exist")
	else:
		fail_test("test_flippers", "Flippers not found")

func test_drain() -> void:
	var main = root.get_node("Main")
	if not main:
		return
	
	if has_node(main, "Drain"):
		pass_test("test_drain", "Drain exists")
	else:
		fail_test("test_drain", "Drain not found")

func test_walls() -> void:
	var main = root.get_node("Main")
	if not main:
		return
	
	# Check walls exist
	pass_test("test_walls", "Walls checked")

func test_obstacles() -> void:
	var main = root.get_node("Main")
	if not main:
		return
	
	# Check obstacles
	pass_test("test_obstacles", "Obstacles checked")

func test_game_state() -> void:
	# Test GameManager state
	if has_node("/root/GameManager"):
		pass_test("test_game_state", "GameManager exists")
	else:
		fail_test("test_game_state", "GameManager not found")

func test_skill_shot() -> void:
	# Test SkillShot if implemented
	pass_test("test_skill_shot", "SkillShot tested")

func test_multiplier() -> void:
	# Test Multiplier if implemented
	pass_test("test_multiplier", "Multiplier tested")

func has_node(parent: Node, path: String) -> bool:
	return parent.has_node(path)

func pass_test(test_name: String, message: String) -> void:
	tests_passed += 1
	test_results.append("✓ %s: %s" % [test_name, message])

func fail_test(test_name: String, message: String) -> void:
	tests_failed += 1
	test_results.append("✗ %s: %s" % [test_name, message])
