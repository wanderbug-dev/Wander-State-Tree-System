@tool
class_name WStateTreeCondition
extends Resource


enum LogicalConnective {AND, OR}


@export var inverse : bool = false
@export var connective : LogicalConnective = LogicalConnective.AND


func _init() -> void:
	pass

func _check_condition(context : Dictionary)->bool:
	return true

func _result(context : Dictionary)->bool:
	if inverse:
		return !_check_condition(context)
	else:
		return _check_condition(context)
