# Unit Tests - CoordinateConverter (pure functions)
extends GutTest

# CoordinateConverter is autoloaded, so we can call static methods directly

func test_flutter_to_godot_origin():
	var result = CoordinateConverter.flutter_to_godot(Vector2(0, 0))
	assert_almost_eq(result.x, 400.0, 0.01, "x = 0*5+400")
	assert_almost_eq(result.y, 300.0, 0.01, "y = 0*5+300")

func test_flutter_to_godot_positive():
	var result = CoordinateConverter.flutter_to_godot(Vector2(20, 40))
	assert_almost_eq(result.x, 500.0, 0.01, "x = 20*5+400")
	assert_almost_eq(result.y, 500.0, 0.01, "y = 40*5+300")

func test_flutter_to_godot_negative():
	var result = CoordinateConverter.flutter_to_godot(Vector2(-10, -20))
	assert_almost_eq(result.x, 350.0, 0.01, "x = -10*5+400")
	assert_almost_eq(result.y, 200.0, 0.01, "y = -20*5+300")

func test_flutter_impulse_to_godot_zero():
	var result = CoordinateConverter.flutter_impulse_to_godot(Vector2.ZERO)
	assert_eq(result, Vector2.ZERO, "zero impulse stays zero")

func test_flutter_impulse_to_godot_scaled():
	var result = CoordinateConverter.flutter_impulse_to_godot(Vector2(100, -50))
	assert_almost_eq(result.x, 500.0, 0.01, "100*5=500")
	assert_almost_eq(result.y, -250.0, 0.01, "-50*5=-250")
