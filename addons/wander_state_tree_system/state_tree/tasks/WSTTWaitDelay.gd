@tool
class_name WSTTWaitDelay
extends WStateTreeTask



@export var delay : float = 1.0

var timer : SceneTreeTimer = null

func _start():
	super()
	timer = state.get_tree().create_timer(delay)
	timer.timeout.connect(handle_timeout)

func _end():
	super()
	cleanup_timer()

func handle_timeout():
	timer = null
	_succeed()

func cleanup_timer():
	if not timer:
		return
	if timer.timeout.is_connected(handle_timeout):
		timer.timeout.disconnect(handle_timeout)
	timer = null
