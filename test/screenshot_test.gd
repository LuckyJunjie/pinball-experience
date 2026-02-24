# Screenshot Test Script
extends SceneTree

func _initialize():
    print("===== 截图测试 =====")
    
    # 加载主场景
    var main = load("res://scenes/Main.tscn").instantiate()
    root.add_child(main)
    await process_frame
    
    # 验证节点存在
    var test_result = {
        "Launcher": main.has_node("Launcher"),
        "FlipperLeft": main.has_node("FlipperLeft"),
        "FlipperRight": main.has_node("FlipperRight"),
        "Drain": main.has_node("Playfield/Drain"),
        "Obstacles": main.has_node("Obstacles"),
        "HUD": main.has_node("UI/Control/HUD")
    }
    
    print("--- 节点验证结果 ---")
    for node in test_result:
        if test_result[node]:
            print("✓ %s" % node)
        else:
            print("✗ %s" % node)
    
    # 创建简单的截图标记文件
    var file = FileAccess.open("res://test/screenshot/current/test_marker.txt", FileAccess.WRITE)
    if file:
        file.store_string("Screenshot test run at: " + Time.get_datetime_string_from_system())
        file.close()
        print("✓ 测试标记文件已创建")
    
    main.free()
    await create_timer(0.5).timeout
    quit()
