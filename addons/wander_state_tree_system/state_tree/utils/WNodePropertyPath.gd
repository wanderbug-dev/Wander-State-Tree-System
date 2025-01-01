class_name WNodePropertyPath
extends WPropertyPath


@export_node_path() var node_path : NodePath


func _get_target_object(source : Object)->Object:
	var start_node := source as Node
	if not start_node:
		return null
	return start_node.get_node_or_null(node_path)
