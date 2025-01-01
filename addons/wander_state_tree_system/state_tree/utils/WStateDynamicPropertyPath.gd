class_name WStateDynamicPropertyPath
extends WNodePropertyPath


func get_property(source : Object)->Variant:
	var target_state := _get_target_object(source) as WState
	if target_state:
		return target_state.get_dynamic_property(property_name)
	return null
		
func set_property(source : Object, value : Variant):
	var target_state := _get_target_object(source) as WState
	if target_state:
		target_state.set_dynamic_property(property_name, value)
