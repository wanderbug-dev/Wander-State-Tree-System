@tool
class_name WSTCGroup
extends WStateTreeCondition


@export var subconditions : Array[WStateTreeCondition]


func _check_condition(in_state : WState)->bool:
	return finalize_result(in_state._check_conditions(subconditions))
