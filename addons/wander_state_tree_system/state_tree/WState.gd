class_name WState
extends Node


enum StateSearchPolicy {SEARCH_CHILDREN, STOP_SEARCH, SEARCH_TRANSITIONS}
enum StateProcessOrder {SELF_FIRST, CHILDREN_FIRST}
enum TransitionDefaultPolicy {TO_ROOT, TO_PARENT, TO_SELF, DO_NOTHING}

signal on_transition(new_state : WState)
signal on_recursive_selection(selection : Array[WState])
signal on_selected(state : WState)
signal on_event(event_tag : StringName, event_payload : Dictionary)

signal on_entered(state : WState)
signal on_exited(state : WState)

@export var enabled : bool = true
@export var search_policy : StateSearchPolicy = StateSearchPolicy.SEARCH_CHILDREN
@export var process_order : StateProcessOrder = StateProcessOrder.SELF_FIRST
@export var transition_default_policy : TransitionDefaultPolicy = TransitionDefaultPolicy.TO_ROOT
@export var entry_conditions : Array[WStateTreeCondition]
@export var tasks : Array[WStateTreeTask]
@export var transitions : Array[WStateTreeTransition]

var dynamic_properties : Dictionary[StringName, Variant] = {}
var is_active : bool = false
var root : WState = null
var default_context : Dictionary

func _initialize(in_root_state : WState):
	root = in_root_state
	for task in tasks:
		task._initialize(self)
	for transition in transitions:
		transition._initialize(self)
	for child_state in get_child_states():
		child_state.on_recursive_selection.connect(_handle_recursive_selection)
		child_state._initialize(root)
	in_root_state.on_event.connect(_handle_event)
	default_context = create_new_context()

func _process_state(delta: float):
	for task in tasks:
		task._process_task(delta)

func _physics_process_state(delta : float):
	for task in tasks:
		task._physics_process_task(delta)
	for transition in transitions:
		if transition.is_pending():
			if transition.decrement_pending_time(delta):
				transition_state(transition.get_target_state())
				break
			continue
		if not transition.check_tick_trigger():
			continue
		if _try_transition(transition, default_context):
			if not transition.has_delay():
				break

func _evaluate_entry()->bool:
	if not enabled:
		return false
	return check_conditions(default_context, entry_conditions)

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
	on_selected.emit(self)
	_handle_recursive_selection(selection)

func _handle_recursive_selection(selection : Array[WState]):
	selection.insert(0, self)
	on_recursive_selection.emit(selection)

func _enter():
	if is_active:
		return
	is_active = true
	for task in tasks:
		task.on_request_state_complete.connect(_handle_task_complete)
		task._start()
	on_entered.emit(self)

func _reenter():
	for task in tasks:
		task._restart()

func _exit():
	if not is_active:
		return
	is_active = false
	for task in tasks:
		task.on_request_state_complete.disconnect(_handle_task_complete)
	for task in tasks:
		task._end()
	for transition in transitions:
		transition.clear_pending()
	on_exited.emit(self)

func _event(event_tag : StringName, event_payload : Dictionary[StringName, Variant]):
	add_state_context(self, event_payload)
	_handle_event(event_tag, event_payload)
	on_event.emit(event_tag, event_payload)

func _handle_event(event_tag : StringName, event_payload : Dictionary):
	for transition in transitions:
		if transition.check_event_trigger(event_tag):
			_try_transition(transition, event_payload)

func _handle_task_complete(in_task : WStateTreeTask, was_success : bool):
	add_task_context(in_task, default_context)
	var has_transition : bool = false
	for transition in transitions:
		if transition.check_state_completion_trigger(was_success):
			if _try_transition(transition, default_context):
				has_transition = true
				if not transition.has_delay():
					break
	remove_task_context(default_context)
	if not has_transition:
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
	var next_state : WState = in_transition._evaluate_transition(context)
	if next_state:
		if in_transition.has_delay():
			in_transition.set_pending()
		else:
			transition_state(next_state)
		return true
	return false

func transition_state(in_state : WState):
	for transition in transitions:
		transition.clear_pending()
	on_transition.emit(in_state)

func get_child_states()->Array[WState]:
	var child_states : Array[WState] = []
	for child in get_children():
		var child_state = child as WState
		if child_state:
			child_states.append(child_state)
	return child_states

func get_parent_state()->WState:
	return get_parent() as WState

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
	for transition in transitions:
		if transition.trigger != transition.Trigger.ON_SEARCH:
			continue
		if not transition._evaluate_transition(default_context):
			continue
		var next_state : WState = transition.get_target_state()
		return next_state._search()
	return self

func set_dynamic_property(property_name : StringName, value : Variant):
	dynamic_properties[property_name] = value

func get_dynamic_property(property_name: StringName)->Variant:
	if has_dynamic_property(property_name):
		return dynamic_properties[property_name]
	return null

func has_dynamic_property(property_name : StringName)->bool:
	return dynamic_properties.has(property_name)

func create_new_context()->Dictionary:
	var context : Dictionary = {}
	add_root_context(root, context)
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

func get_task_index(in_task : WStateTreeTask)->int:
	return tasks.find(in_task)

static func add_root_context(root : WState, in_context : Dictionary):
	in_context["root"] = root

static func get_root_context(context : Dictionary)->WState:
	if context.has("root"):
		return context["root"] as WState
	return null

static func add_state_context(state : WState, in_context : Dictionary):
	in_context["state"] = state

static func get_state_context(context : Dictionary)->WState:
	if context.has("state"):
		return context["state"] as WState
	return null

static func add_task_context(task : WStateTreeTask, in_context : Dictionary):
	in_context["task"] = task

static func remove_task_context(in_context : Dictionary):
	in_context.erase("task")

static func get_task_context(context : Dictionary)->WStateTreeTask:
	if context.has("task"):
		return context["task"] as WStateTreeTask
	return null
