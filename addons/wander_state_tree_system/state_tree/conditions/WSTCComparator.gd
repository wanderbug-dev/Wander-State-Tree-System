@tool
class_name WSTTCComparator
extends WStateTreeCondition


@export var target_property : WPropertyPath
## valid keys: =, >, <
@export var compare_values : Dictionary[StringName, Variant] = {"=" : null}


func _check_condition(context : Dictionary)->bool:
	if compare_values.is_empty():
		return false
	var source_state := WState.get_state_context(context)
	var target_value = target_property.get_property(source_state)
	for comparison_type in compare_values.keys():
		var value = compare_values[comparison_type]
		if not typeof(target_value) == typeof(value):
			return false
		if comparison_type == "=" or comparison_type == "==":
			if not target_value == value:
				return false
		if comparison_type == ">":
			if not target_value > value:
				return false
		if comparison_type == "<":
			if not target_value < value:
				return false
	return true
