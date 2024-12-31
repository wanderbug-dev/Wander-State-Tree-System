class_name WPropertyPath
extends Resource


@export_node_path() var node_path : NodePath
@export var property_name : StringName


func get_property(start_node : Node)->Variant:
	var target_node : Node = start_node.get_node_or_null(node_path)
	if target_node:
		return target_node.get(property_name)
	return null
		
func set_property(start_node : Node, value : Variant):
	var target_node : Node = start_node.get_node_or_null(node_path)
	if target_node:
		target_node.set(property_name, value)
