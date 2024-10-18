@tool
extends EditorScript


func _find_node_by_name(node_name:String, n:Node) -> Node:
	if n.name.contains(node_name): return n
	for c in n.get_children():
		var result := _find_node_by_name(node_name, c)
		if result:
			return result
	return null



func _run() -> void:
	var base_control := EditorInterface.get_base_control()
	print("base control path: %s" % base_control.get_path())
	var editor_scene_tabs := _find_node_by_name("EditorSceneTabs", base_control)
	if !editor_scene_tabs:
		print("Did not find editor scene tabs!!")
		return
	print("editor scene tabs path: %s" % editor_scene_tabs.get_path())
	var tab_bar:TabBar = _find_node_by_name("TabBar", editor_scene_tabs)
	if !tab_bar:
		print("Did not find tab bar!!")
		return
	print("tab bar path: %s" % tab_bar.get_path())
	#var open_scenes := EditorInterface.get_open_scenes()
	#var index := open_scenes.find("res://scenes/level/level_base.tscn")
	#if index < 0:
		#print("did not find index")
		#return
	#tab_bar.tab_close_pressed.emit(index)
	#print("tab closed")
