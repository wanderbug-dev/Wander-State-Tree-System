@tool
class_name WTaskPropertyPath
extends WPropertyPath


enum TaskSearch {BY_ID, BY_INDEX}

@export var task_search : TaskSearch = TaskSearch.BY_ID
@export var task_index : int
@export var task_id : String


func get_property(start_node : Node)->Variant:
	var target_state := start_node.get_node_or_null(node_path) as WState
	if target_state:
		var target_task : WStateTreeTask = null
		if task_search == TaskSearch.BY_ID:
			target_task = target_state.get_task_by_id(task_id)
		if task_search == TaskSearch.BY_INDEX:
			target_task = target_state.get_task_by_index(task_index)
		if target_task:
			return target_task.get_indexed(property_name)
	return null
		
func set_property(start_node : Node, value : Variant):
	var target_state := start_node.get_node_or_null(node_path) as WState
	if target_state:
		var target_task := target_state.get_task_by_id(task_id)
		if target_task:
			target_task.set_indexed(property_name, value)
