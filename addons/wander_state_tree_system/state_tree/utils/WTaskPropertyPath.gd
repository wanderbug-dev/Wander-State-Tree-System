@tool
class_name WTaskPropertyPath
extends WPropertyPath


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
