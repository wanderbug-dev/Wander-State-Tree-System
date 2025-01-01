@tool
class_name WSTCTaskID
extends WStateTreeCondition


@export var required_task_ID : String

func _check_condition(context : Dictionary)->bool:
	var task : WStateTreeTask = WState.get_task_context(context)
	if task and task.ID == required_task_ID:
		return true
	return false
