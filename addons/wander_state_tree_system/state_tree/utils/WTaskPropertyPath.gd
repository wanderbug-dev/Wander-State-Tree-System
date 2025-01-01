@tool
class_name WTaskPropertyPath
extends WNodePropertyPath


enum TaskSearch {BY_ID, BY_INDEX}

@export var task_search : TaskSearch = TaskSearch.BY_ID:
	set(value):
		if value == task_search:
			return
		task_search = value
		notify_property_list_changed()

@export_storage var task_index : int
@export_storage var task_id : String


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

func _get_target_object(source : Object)->Object:
	var start_node := super(source) as Node
	if not start_node:
		return null
	var target_state := start_node.get_node_or_null(node_path) as WState
	if target_state:
		if task_search == TaskSearch.BY_ID:
			return target_state.get_task_by_id(task_id)
		if task_search == TaskSearch.BY_INDEX:
			return target_state.get_task_by_index(task_index)
	return null
