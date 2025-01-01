@tool
class_name WSTCGroup
extends WStateTreeCondition


@export var subconditions : Array[WStateTreeCondition]


func _check_condition(context)->bool:
	return WState.check_conditions(context, subconditions)
