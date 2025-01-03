@tool
class_name WSTTDebugPrint
extends WStateTreeTask


@export var debug_message : String
@export var debug_color : Color = Color(0.82, 0.82, 0.82)


func _init() -> void:
	super()
	if Engine.is_editor_hint():
		completion_policy = TaskCompletionPolicy.DO_NOTHING

func _start():
	super()
	var color_string : String = "[color=" + debug_color.to_html(false) + "]"
	print_rich(color_string, get_script().get_global_name(), ": ", debug_message, "[/color]")
	_succeed()
