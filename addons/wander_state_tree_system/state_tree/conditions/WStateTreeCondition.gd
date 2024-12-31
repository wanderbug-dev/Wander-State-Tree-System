@tool
class_name WStateTreeCondition
extends Resource


enum LogicalConnective {AND, OR}


@export var inverse : bool = false
@export var connective : LogicalConnective = LogicalConnective.AND


func _init() -> void:
	if Engine.is_editor_hint():
		resource_local_to_scene = true

func _check_condition(in_state : WState)->bool:
	return finalize_result(true)

func finalize_result(in_result : bool)->bool:
	if inverse:
		return !in_result
	else:
		return in_result
