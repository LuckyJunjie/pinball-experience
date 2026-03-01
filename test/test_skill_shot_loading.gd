# 测试 SkillShot 加载 - 调试版
extends SceneTree

func _initialize():
	print("===== 测试 SkillShot 加载 =====")
	print("开始...")
	
	# 使用 ResourceLoader
	var skill_shot_scene = ResourceLoader.load("res://scenes/SkillShot.tscn")
	print("ResourceLoader.load 返回: " + str(skill_shot_scene))
	
	if skill_shot_scene == null:
		print("✗ SkillShot.tscn 加载失败")
		
		# 列出所有 .tscn 文件
		print("\n可用的 .tscn 文件:")
		var dir = DirAccess.open("res://scenes/")
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".tscn"):
					print("  - " + file_name)
				file_name = dir.get_next()
		
		quit()
		return
	
	print("✓ SkillShot.tscn 加载成功")
	quit()
