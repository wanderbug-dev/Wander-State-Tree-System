@tool
class_name WStateTreeTask
extends Resource


signal on_task_complete(completed_task : WStateTreeTask, success : bool)

var state : WState = null
var is_active : bool = false

func _init() -> void:
	if Engine.is_editor_hint():
		resource_local_to_scene = true

func _initialize(in_state : WState):
	state = in_state

func _process_task(delta : float):
	pass

func _physics_process_task(delta : float):
	pass

func _start():
	is_active = true

func _restart():
	pass

func _end():
	is_active = false

func _succeed():
	_complete(true)

func _fail():
	_complete(false)

func _complete(success : bool):
	_end()
	on_task_complete.emit(self, success)

func test()->void:
	pass
