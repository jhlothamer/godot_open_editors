@tool
class_name OpenEditorsItem
extends PanelContainer

static var _CLASS:PackedScene = preload("uid://y0pvfmmdk6oe")

@onready var _outline:Control = $Outline
@onready var _close_btn:Button = %CloseBtn
@onready var _label:Label = %TextLabel
@onready var _icon:TextureRect = %IconTextureRect
@onready var _play_btn:Button = %PlaySceneBtn

var scene_path := ""
var display_name := ""
var editor_tab_bar:TabBar
var icon:Texture2D

# used to prevent changes to scene while editing
var _created := false

func _ready() -> void:
	if !_created: return
	_outline.visible = false
	_label.text = display_name
	tooltip_text = "%s\n(right click - copy path,\nmiddle click - copy UID)" % scene_path
	_close_btn.modulate = Color.TRANSPARENT
	_play_btn.modulate = Color.TRANSPARENT
	if icon: _icon.texture = icon


func _on_close_btn_pressed() -> void:
	if !editor_tab_bar:
		return
	var open_scenes := EditorInterface.get_open_scenes()
	var index := open_scenes.find(scene_path)
	if index >= 0:
		editor_tab_bar.tab_close_pressed.emit(index)
	queue_free()


func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.is_pressed(): return
	var mb:InputEventMouseButton = event
	if mb.button_index == MOUSE_BUTTON_LEFT:
		EditorInterface.open_scene_from_path(scene_path)
	elif mb.button_index == MOUSE_BUTTON_RIGHT:
		DisplayServer.clipboard_set(scene_path)
		print("Path for scene copied to clipboard: %s" % scene_path)
	elif mb.button_index == MOUSE_BUTTON_MIDDLE:
		var uid := ResourceUID.path_to_uid(scene_path)
		DisplayServer.clipboard_set(uid)
		print("UID for scene '%s' copied to clipboard: %s" % [scene_path, uid])


func _on_mouse_entered() -> void:
	_outline.visible = true
	_close_btn.modulate = Color.WHITE
	_play_btn.modulate = Color.WHITE


func _on_mouse_exited() -> void:
	_outline.visible = false
	_close_btn.modulate = Color.TRANSPARENT
	_play_btn.modulate = Color.TRANSPARENT


func _on_play_scene_btn_pressed() -> void:
	EditorInterface.play_custom_scene(scene_path)


static func create() -> OpenEditorsItem:
	var item:OpenEditorsItem = _CLASS.instantiate()
	item._created = true
	return item
