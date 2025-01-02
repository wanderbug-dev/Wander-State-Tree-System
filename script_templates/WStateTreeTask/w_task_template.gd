# meta-name: State Tree Task
# meta-description: 
# meta-default: true
# meta-space-indent: 4

extends WStateTreeTask


func _init() -> void:
	super()

func _initialize(in_state : WState):
	super(in_state)

func _process_task(delta : float):
	pass

func _physics_process_task(delta : float):
	pass

func _start():
	super()

func _restart(force_restart : bool = false):
	super(force_restart)

func _end():
	super()

func _succeed():
	super()

func _fail():
	super()

func _complete(success : bool):
	super(success)
