@tool
class_name WStateTreeTransition
extends Resource


enum Trigger {
	ON_STATE_COMPLETED,
	ON_STATE_SUCCEEDED,
	ON_STATE_FAILED,
	ON_TICK,
	ON_EVENT,
	ON_SEARCH
	}

@export var trigger : Trigger = Trigger.ON_STATE_COMPLETED:
	set(value):
		if trigger == value:
			return
		trigger = value
		notify_property_list_changed()
@export var conditions : Array[WStateTreeCondition]
@export var delay : float = 0
@export_node_path("WState") var target_state : NodePath
@export_storage var event_tag : StringName

var state : WState = null
var pending_time : float = 0

func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary]
	if Engine.is_editor_hint():
		if trigger == Trigger.ON_EVENT:
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

func _initialize(in_state : WState):
	state = in_state

func _evaluate_transition(context : Dictionary)->WState:
	var new_state := get_target_state()
	if not new_state:
		return null
	if not new_state._evaluate_entry():
		return null
	if not state.check_conditions(context, conditions):
		return null
	return new_state

func get_target_state()->WState:
	return state.get_node_or_null(target_state) as WState

func check_trigger(in_trigger : Trigger)->bool:
	return in_trigger == trigger

func check_state_completion_trigger(success : bool)->bool:
	if trigger == Trigger.ON_STATE_COMPLETED:
		return true
	if trigger == Trigger.ON_STATE_SUCCEEDED:
		return success
	if trigger == Trigger.ON_STATE_FAILED:
		return !success
	return false

func check_tick_trigger()->bool:
	return trigger == Trigger.ON_TICK

func check_event_trigger(in_event_tag : StringName)->bool:
	if trigger == Trigger.ON_EVENT:
		return in_event_tag == event_tag
	return false

func has_delay()->bool:
	return delay > 0

func is_pending()->bool:
	return pending_time > 0

func set_pending():
	pending_time = delay

func decrement_pending_time(delta : float)->bool:
	pending_time -= delta
	return !is_pending()

func clear_pending():
	pending_time = 0
