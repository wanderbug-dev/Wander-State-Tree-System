@tool
class_name WSTCTaskID
extends WStateTreeCondition


@export var required_task_id : String

func _check_condition(context : Dictionary)->bool:
	var task : WStateTreeTask = WState.get_task_context(context)
	if task and task.id == required_task_id:
		return true
	return false
