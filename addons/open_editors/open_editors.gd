@tool
extends Control

const _ITEM_SCENE = preload("res://addons/open_editors/open_editors_item.tscn")


@onready var _items:VBoxContainer = %OpenEditorItems
@onready var _refresh_timer:Timer = $RefreshTimer


var _editor_tab_bar:TabBar
var _prev_open_scenes:PackedStringArray = []
var _filter := ""


func _ready() -> void:
	_editor_tab_bar = _get_editor_tab_bar()
	if !_editor_tab_bar:
		printerr("Open Editors: could not find editor scen tab bar - please submit github issue")
		return
	_refresh_list.call_deferred()
	_refresh_timer.start()


func _refresh_list(force_update: bool = false) -> void:
	var tab_titles = _get_editor_scene_tab_titles()
	if not _diff_from_prev(tab_titles) and not force_update: return

	_clear()
	
	var open_scenes := EditorInterface.get_open_scenes()
	
	# map file names to indices in the open_scenes/tab_titles arrays
	var filenames_to_indices := {}
	for i in open_scenes.size():
		var open_scene := open_scenes[i]
		var filename = open_scene.get_file()
		if not _filter.is_empty() and not filename.contains(_filter): continue
		if filenames_to_indices.has(filename):
			filenames_to_indices[filename].append(i)
		else:
			filenames_to_indices[filename] = [i]
	
	var sorted_filenames := filenames_to_indices.keys()
	sorted_filenames.sort()


	for filename:String in sorted_filenames:
		var indices:Array = filenames_to_indices[filename]
		if indices.size() == 1:
			# filename is not duplicated
			_add_item(open_scenes[indices[0]], filename, _editor_tab_bar.get_tab_icon(indices[0]))
			continue
		
		var file_extension = filename.get_extension()
		#sort by tab title
		var tab_titles_for_filename:Array[String]= []
		for index:int in indices:
			tab_titles_for_filename.append(tab_titles[index])
		tab_titles_for_filename.sort()
		for tab_title in tab_titles_for_filename:
			var index = tab_titles.find(tab_title)
			var display_text:String = tab_title if tab_title.ends_with(file_extension) else "%s.%s" % [tab_title, file_extension]
			_add_item(open_scenes[index], display_text, _editor_tab_bar.get_tab_icon(index))


func _add_item(scene_path:String, display_name:String, icon:Texture2D) -> void:
	var item:OpenEditorsItem = _ITEM_SCENE.instantiate()
	item.scene_path = scene_path
	item.display_name = display_name
	item.icon = icon
	item.editor_tab_bar = _editor_tab_bar
	_items.add_child(item)


func _clear() -> void:
	for c:Node in _items.get_children():
		c.queue_free()


func _diff_from_prev(open_scenes:PackedStringArray) -> bool:
	var sorted_open_scenes := PackedStringArray(open_scenes)
	sorted_open_scenes.sort()

	if _prev_open_scenes.size() != sorted_open_scenes.size():
		_prev_open_scenes = sorted_open_scenes
		return true
	
	for i in _prev_open_scenes.size():
		if _prev_open_scenes[i] != sorted_open_scenes[i]:
			_prev_open_scenes = sorted_open_scenes
			return true
	
	return false


func _get_editor_scene_tab_titles() -> PackedStringArray:
	var titles:PackedStringArray = []
	for i in _editor_tab_bar.tab_count:
		var tab_title := _editor_tab_bar.get_tab_title(i)
		if _filter.is_empty() or tab_title.contains(_filter):
			titles.append(tab_title)
	return titles


func _find_node_by_name(node_name:String, n:Node) -> Node:
	if n.name.contains(node_name): return n
	for c:Node in n.get_children():
		var result := _find_node_by_name(node_name, c)
		if result:
			return result
	return null


func _get_editor_tab_bar() -> TabBar:
	var base_control := EditorInterface.get_base_control()
	var editor_scene_tabs := _find_node_by_name("EditorSceneTabs", base_control)
	if !editor_scene_tabs:
		return null
	var tab_bar:TabBar = _find_node_by_name("TabBar", editor_scene_tabs)
	if !tab_bar:
		return null
	return tab_bar


func _on_refresh_timer_timeout() -> void:
	_refresh_list()


func _on_filter_line_edit_text_changed(new_text:String ) -> void:
	_filter = new_text.strip_edges()
	_refresh_list(true)
