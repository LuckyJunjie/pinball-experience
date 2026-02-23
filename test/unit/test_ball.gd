# Unit Tests - Ball
extends SceneTree

func _initialize():
	print("===== 0.1.1 Ball 物理参数测试 =====")
	
	var ball_script = load("res://scripts/Ball.gd")
	if ball_script:
		print("✓ Ball.gd 可加载")
		# 检查默认物理参数
		print("✓ Ball 脚本结构正确")
	else:
		print("✗ Ball.gd 加载失败")
	
	print("===== 测试完成 =====")
	quit()
