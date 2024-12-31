@tool
class_name WStateTreeTransition
extends Resource


enum StateTrigger {ON_STATE_COMPLETED, ON_STATE_SUCCEEDED, ON_STATE_FAILED, ON_TICK, ON_EVENT, ON_SEARCH}

@export var trigger : StateTrigger = StateTrigger.ON_STATE_COMPLETED
@export var conditions : Array[WStateTreeCondition]
@export_node_path("WState") var target_state : NodePath

var state : WState = null

func _init() -> void:
	if Engine.is_editor_hint():
		resource_local_to_scene = true

func _initialize(in_state : WState):
	state = in_state

func _evaluate_transition()->WState:
	var new_state := get_target_state()
	if not new_state:
		return null
	if not new_state._evaluate_entry():
		return null
	if not state._check_conditions(conditions):
		return null
	return new_state

func get_target_state()->WState:
	return state.get_node_or_null(target_state) as WState
