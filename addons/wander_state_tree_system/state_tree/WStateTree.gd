class_name WStateTree
extends WState


@export var self_initialize: bool = true

var state_tree_owner : Node = null
var target_state : WState = null
var selected_states : Array[WState] = []
var active_states : Array[WState] = []
var process_states : Array[WState] = []


func _ready() -> void:
	if self_initialize:
		_initialize(self)

func _initialize(in_root_state : WState):
	super(in_root_state)
	_select_state(_search())

func _process(delta: float) -> void:
	for process_state in process_states:
		process_state._process_state(delta)

func _physics_process(delta: float) -> void:
	for process_state in process_states:
		process_state._physics_process_state(delta)

func _select_state(in_state : WState):
	selected_states.clear()
	if not in_state:
		return
	if active_states.has(in_state):
		_exit_active_branch(in_state)
	target_state = in_state._search()
	target_state._selected(selected_states)

func _exit_active_branch(start_state : WState):
	var pending_index : int = active_states.find(start_state)
	var pending_states : Array[WState] = active_states.slice(pending_index)
	pending_states.reverse()
	for pending_state in pending_states:
		_exit_state(pending_state)
	active_states.resize(pending_index)

func _handle_state_transition(in_state : WState):
	_select_state(in_state)

func _selected(selection : Array[WState]):
	super(selection)

func _handle_recursive_selection(selection : Array[WState]):
	super(selection)
	active_states.reverse()
	for active_state in active_states:
		if not selected_states.has(active_state):
			_exit_state(active_state)
	for selected_state in selected_states:
		if not active_states.has(selected_state):
			_enter_state(selected_state)
		else:
			_reenter_state(selected_state)
	active_states.assign(selected_states)
	process_states.clear()
	var deferred_states : Array[WState] = []
	for active_state in active_states:
		if active_state.process_order == active_state.StateProcessOrder.CHILDREN_FIRST:
			deferred_states.insert(0, active_state)
		else:
			process_states.append(active_state)
	if not deferred_states.is_empty():
		process_states.append_array(deferred_states)

func _enter_state(in_state : WState):
	in_state.on_transition.connect(_handle_state_transition)
	in_state._enter()

func _reenter_state(in_state : WState):
	in_state._reenter()

func _exit_state(in_state : WState):
	in_state._exit()
	in_state.on_transition.disconnect(_handle_state_transition)

func _enter():
	super()

func _exit():
	super()

func get_branch(end_state : WState)->Array[WState]:
	var branch_path : String = get_path_to(end_state)
	var branch_segments := branch_path.split("/", false)
	var branch_states : Array[WState]
	branch_path = ""
	for segment in branch_segments:
		if branch_path.is_empty():
			branch_path = segment
		else:
			branch_path = branch_path + "/" + segment
		var branch_state := get_node(branch_path) as WState
		branch_states.append(branch_state)
	return branch_states
