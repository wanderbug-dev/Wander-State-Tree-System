@tool
class_name WStateTreeTask
extends Resource


signal on_task_complete(completed_task : WStateTreeTask, success : bool)

@export var ID : String
@export var restart_on_reentry : bool = false
@export var finish_state : bool = true

var state : WState = null
var is_active : bool = false


func _init() -> void:
	if Engine.is_editor_hint():
		resource_local_to_scene = true
		ID = generate_scene_unique_id()

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
	on_task_complete.emit(self, success)

func test()->void:
	pass
