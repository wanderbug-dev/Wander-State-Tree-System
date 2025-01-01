class_name WStateDynamicPropertyPath
extends WPropertyPath


func get_property(start_node : Node)->Variant:
	var target_state := start_node.get_node_or_null(node_path) as WState
	if target_state:
		return target_state.get_dynamic_property(property_name)
	return null

func set_property(start_node : Node, value : Variant):
	var target_state := start_node.get_node_or_null(node_path) as WState
	if target_state:
		target_state.set_dynamic_property(property_name, value)
