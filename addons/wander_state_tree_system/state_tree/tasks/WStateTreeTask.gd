@tool
class_name WStateTreeTask
extends Resource


enum TaskCompletionPolicy { COMPLETE_STATE, SEND_EVENT, DO_NOTHING}

signal on_task_complete(completed_task : WStateTreeTask, success : bool)
signal on_request_state_complete(completed_task : WStateTreeTask, success : bool)

@export var id : StringName:
	set(value):
		id = value
		if id.is_empty():
			id = generate_scene_unique_id()
@export var restart_on_reentry : bool = false
@export var completion_policy : TaskCompletionPolicy = TaskCompletionPolicy.COMPLETE_STATE:
	set(value):
		if completion_policy == value:
			return
		completion_policy = value
		notify_property_list_changed()
@export_category("Completion Event")
@export_storage var event_target : NodePath
@export_storage var event_tag : StringName

var state : WState = null
var is_active : bool = false


func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary]
	if Engine.is_editor_hint():
		if completion_policy == TaskCompletionPolicy.SEND_EVENT:
			ret.append({
				"name" : &"event_target",
				"type" : TYPE_NODE_PATH,
				"usage" : PROPERTY_USAGE_DEFAULT
			})
			ret.append({
				"name" : &"event_tag",
				"type" : TYPE_STRING_NAME,
				"usage" : PROPERTY_USAGE_DEFAULT
			})
		return ret
	return ret

func _init() -> void:
	if Engine.is_editor_hint():
		resource_local_to_scene = true
		if id.is_empty():
			id = generate_scene_unique_id()

func _initialize(in_state : WState):
	state = in_state

func _process_task(delta : float):
	pass

func _physics_process_task(delta : float):
	pass

func _start():
	is_active = true

func _restart(force_restart : bool = false):
	if (not is_active and restart_on_reentry) or force_restart:
		_start()

func _end():
	is_active = false

func _succeed():
	_complete(true)

func _fail():
	_complete(false)

func _complete(success : bool):
	_end()
	on_task_complete.emit.call_deferred(self, success)
	if completion_policy == TaskCompletionPolicy.COMPLETE_STATE:
		on_request_state_complete.emit.call_deferred(self, success)
	if completion_policy == TaskCompletionPolicy.SEND_EVENT:
		_send_event.call_deferred(success)

func _send_event(success : bool):
	var target_state := state.get_node(event_target) as WState
	if target_state:
		var payload : Dictionary[StringName, Variant]
		payload["success"] = success
		payload["sender"] = state
		target_state._event(event_tag, payload)
