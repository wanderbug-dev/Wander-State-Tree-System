@tool
class_name WSTTDebugPrint
extends WStateTreeTask


@export var debug_message : String

func _start():
	super()
	print(self, ": ", debug_message)
	
func _process_task(delta : float):
	super(delta)
