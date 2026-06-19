@tool
extends EditorPlugin

const _OPEN_EDITORS_SCENE = preload("uid://djrhxv5bx0bbw")

var _open_editors:Control

func _enter_tree() -> void:
	_open_editors = _OPEN_EDITORS_SCENE.instantiate()
	_open_editors._created = true
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _open_editors)


func _exit_tree() -> void:
	if _open_editors:
		remove_control_from_docks(_open_editors)
		_open_editors.queue_free()
