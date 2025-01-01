@tool
class_name WSTCTaskID
extends WStateTreeCondition


enum TaskSearch {BY_ID, BY_INDEX}

@export var task_search : TaskSearch = TaskSearch.BY_ID
@export var task_index : int
@export var task_id : String


func _check_condition(context : Dictionary)->bool:
	var task : WStateTreeTask = WState.get_task_context(context)
	var state : WState = WState.get_state_context(context)
	var index : int = -1
	if task:
		if state:
			index = state.tasks.find(task)
	if task_search == TaskSearch.BY_ID:
		return task_id == task.id
	if task_search == TaskSearch.BY_INDEX:
		return task_index == index
	return false
