class_name WPropertyPath
extends Resource

@export var property_name : String


func get_property(source : Object)->Variant:
	return _get_target_object(source).get_indexed(property_name)
		
func set_property(source : Object, value : Variant):
	_get_target_object(source).set_indexed(property_name, value)

func _get_target_object(source : Object)->Object:
	return source
