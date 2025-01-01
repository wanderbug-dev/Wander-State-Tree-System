@tool
class_name WSTCTaskID
extends WStateTreeCondition


enum TaskSearch {BY_ID, BY_INDEX}

@export var task_search : TaskSearch = TaskSearch.BY_ID:
	set(value):
		if value == task_search:
			return
		task_search = value
		notify_property_list_changed()

var task_index : int
var task_id : String


func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary]
	if Engine.is_editor_hint():
		if task_search == TaskSearch.BY_INDEX:
			ret.append({
				"name" : &"task_index",
				"type" : TYPE_INT,
				"usage" : PROPERTY_USAGE_DEFAULT
			})
		if task_search == TaskSearch.BY_ID:
			ret.append({
				"name" : &"task_id",
				"type" : TYPE_STRING,
				"usage" : PROPERTY_USAGE_DEFAULT
			})
		return ret
	return ret

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
