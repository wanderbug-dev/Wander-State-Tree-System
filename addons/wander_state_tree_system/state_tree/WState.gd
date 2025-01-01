class_name WState
extends Node


enum StateSearchPolicy {SEARCH_CHILDREN, STOP_SEARCH, SEARCH_TRANSITIONS}
enum StateProcessOrder {SELF_FIRST, CHILDREN_FIRST}
enum TransitionDefaultPolicy {TO_ROOT, TO_PARENT, TO_SELF, DO_NOTHING}

signal on_transition(new_state : WState)
signal on_selected(selection : Array[WState])

@export var enabled : bool = true
@export var search_policy : StateSearchPolicy = StateSearchPolicy.SEARCH_CHILDREN
@export var process_order : StateProcessOrder = StateProcessOrder.SELF_FIRST
@export var transition_default_policy : TransitionDefaultPolicy = TransitionDefaultPolicy.TO_ROOT
@export var entry_conditions : Array[WStateTreeCondition]
@export var tasks : Array[WStateTreeTask]
@export var transitions : Array[WStateTreeTransition]
@export var test_task : WStateTreeTask

var dynamic_properties : Dictionary[StringName, Variant] = {}
var is_active : bool = false
var root : WState = null


func _ready() -> void:
	pass

func _initialize(in_root_state : WState):
	root = in_root_state
	for task in tasks:
		task._initialize(self)
	for transition in transitions:
		transition._initialize(self)
	for child_state in get_child_states():
		child_state.on_selected.connect(_handle_child_selected_recursive)
		child_state._initialize(root)

func _process_state(delta: float):
	for task in tasks:
		task._process_task(delta)
	var context : Dictionary
	add_state_context(self, context)
	for transition in transitions:
		if transition.trigger != transition.StateTrigger.ON_TICK:
			continue
		var new_state : WState = transition._evaluate_transition(context)
		if new_state:
			transition_state(new_state)
			break

func _physics_process_state(delta : float):
	for task in tasks:
		task._physics_process_task(delta)

func _evaluate_entry()->bool:
	if not enabled:
		return false
	var context := create_new_context()
	return check_conditions(context, entry_conditions)

static func check_conditions(context : Dictionary, in_conditions : Array[WStateTreeCondition])->bool:
	if in_conditions.size() == 0:
		return true
	var successful_condition : bool = false
	for condition in in_conditions:
		if not condition._result(context):
			if condition.connective == condition.LogicalConnective.AND:
				return false
		else:
			successful_condition = true
	return successful_condition

func _selected(selection : Array[WState]):
	_handle_child_selected_recursive(selection)

func _handle_child_selected_recursive(selection : Array[WState]):
	selection.insert(0, self)
	on_selected.emit(selection)

func _enter():
	if is_active:
		return
	is_active = true
	for task in tasks:
		task.on_task_complete.connect(_handle_task_complete)
		task._start()

func _reenter():
	for task in tasks:
		task._restart()

func _exit():
	if not is_active:
		return
	is_active = false
	for task in tasks:
		task.on_task_complete.disconnect(_handle_task_complete)
	for task in tasks:
		task._end()

func set_dynamic_property(property_name : StringName, value : Variant):
	dynamic_properties[property_name] = value

func get_dynamic_property(property_name: StringName)->Variant:
	if has_dynamic_property(property_name):
		return dynamic_properties[property_name]
	return null

func has_dynamic_property(property_name : StringName)->bool:
	return dynamic_properties.has(property_name)

func get_child_states()->Array[WState]:
	var child_states : Array[WState] = []
	for child in get_children():
		var child_state = child as WState
		if child_state:
			child_states.append(child_state)
	return child_states

func get_parent_state()->WState:
	return get_parent() as WState

func _handle_task_complete(in_task : WStateTreeTask, was_success : bool):
	if in_task.finish_state == false:
		return
	var context : Dictionary = create_new_context()
	add_task_context(in_task, context)
	for transition in transitions:
		if transition.trigger == transition.StateTrigger.ON_STATE_COMPLETED:
			if _try_transition(transition, context):
				return
		elif transition.trigger == transition.StateTrigger.ON_STATE_SUCCEEDED and was_success:
			if _try_transition(transition, context):
				return
		elif transition.trigger == transition.StateTrigger.ON_STATE_FAILED and not was_success:
			if _try_transition(transition, context):
				return
	_default_transition()

func _default_transition():
	if transition_default_policy == TransitionDefaultPolicy.TO_ROOT:
		transition_state(root)
	if transition_default_policy == TransitionDefaultPolicy.TO_PARENT:
		transition_state(get_parent_state())
	if transition_default_policy == TransitionDefaultPolicy.TO_SELF:
		transition_state(self)
	if transition_default_policy == TransitionDefaultPolicy.DO_NOTHING:
		return

func _try_transition(in_transition : WStateTreeTransition, context : Dictionary)->bool:
	var new_state : WState = in_transition._evaluate_transition(context)
	if new_state:
		transition_state(new_state)
		return true
	return false

func transition_state(in_state : WState):
	on_transition.emit(in_state)

func _search()->WState:
	if search_policy == StateSearchPolicy.SEARCH_CHILDREN:
		return search_children()
	if search_policy == StateSearchPolicy.SEARCH_TRANSITIONS:
		return search_transitions()
	if search_policy == StateSearchPolicy.STOP_SEARCH:
		return self
	return self

func search_children()->WState:
	for child_state in get_child_states():
		if child_state._evaluate_entry():
			return child_state._search()
	return self

func search_transitions()->WState:
	var context : Dictionary = create_new_context()
	for transition in transitions:
		if transition.trigger != transition.StateTrigger.ON_SEARCH:
			continue
		if not transition._evaluate_transition(context):
			continue
		var next_state : WState = transition.get_target_state()
		return next_state._search()
	return self

func create_new_context()->Dictionary:
	var context : Dictionary = {}
	add_state_context(self, context)
	return context

func get_task_by_id(in_id : String)->WStateTreeTask:
	for task in tasks:
		if task.id == in_id:
			return task
	return null

func get_task_by_index(in_index : int)->WStateTreeTask:
	if tasks.size() > in_index:
		return tasks[in_index]
	return null

static func add_state_context(state : WState, in_context : Dictionary):
	in_context["state"] = state

static func add_task_context(task : WStateTreeTask, in_context : Dictionary):
	in_context["task"] = task

static func get_state_context(context : Dictionary)->WState:
	if context.has("state"):
		return context["state"] as WState
	return null

static func get_task_context(context : Dictionary)->WStateTreeTask:
	if context.has("task"):
		return context["task"] as WStateTreeTask
	return null
