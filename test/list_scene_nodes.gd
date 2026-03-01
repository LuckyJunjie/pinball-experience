# 列出场景节点 - 详细版
extends SceneTree

func _initialize():
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# 等待几帧让场景完全加载
	for i in range(5):
		await process_frame
	
	print("===== Main 场景节点 =====")
	print_nodes(main, "")
	
	# 特别查找 SkillShot
	var skill_shot = main.find_child("SkillShot", true, false)
	if skill_shot:
		print("\n>>> SkillShot found!")
		print(">>> is_active: " + str(skill_shot.is_active))
		print(">>> points: " + str(skill_shot.points))
	else:
		print("\n>>> SkillShot NOT found!")
	
	quit()

func print_nodes(node, indent):
	print(indent + node.name)
	for child in node.get_children():
		print_nodes(child, indent + "  ")
