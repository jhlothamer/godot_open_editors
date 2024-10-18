@tool
class_name OpenEditorsItem
extends PanelContainer


@onready var _outline:Control = $Outline
@onready var _close_btn:TextureButton = %CloseBtn
@onready var _label:Label = %TextLabel
@onready var _icon:TextureRect = %IconTextureRect


var scene_path := ""
var display_name := ""
var editor_tab_bar:TabBar
var icon:Texture2D


func _ready() -> void:
	_outline.visible = false
	_label.text = display_name
	tooltip_text = scene_path
	_close_btn.modulate = Color.TRANSPARENT
	if icon: _icon.texture = icon


func _on_close_btn_pressed() -> void:
	if !editor_tab_bar:
		return
	var open_scenes := EditorInterface.get_open_scenes()
	var index = open_scenes.find(scene_path)
	if index >= 0:
		editor_tab_bar.tab_close_pressed.emit(index)
	queue_free()


func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	var mb:InputEventMouseButton = event
	if mb.button_index == MOUSE_BUTTON_LEFT:
		EditorInterface.open_scene_from_path(scene_path)


func _on_mouse_entered() -> void:
	_outline.visible = true
	_close_btn.modulate = Color.WHITE


func _on_mouse_exited() -> void:
	_outline.visible = false
	_close_btn.modulate = Color.TRANSPARENT


func _on_close_btn_mouse_entered() -> void:
	_outline.visible = true
	_close_btn.modulate = Color.WHITE


func _on_close_btn_mouse_exited() -> void:
	_outline.visible = false
	_close_btn.modulate = Color.TRANSPARENT
