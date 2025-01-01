@tool
class_name WSTTCComparator
extends WStateTreeCondition


enum ComparisonType {EQUALS, GREATER_THAN, LESS_THAN}

@export var target_property : WPropertyPath
@export var compare_values : Dictionary[ComparisonType, Variant] = {ComparisonType.EQUALS : null}

func _check_condition(context : Dictionary)->bool:
	if compare_values.is_empty():
		return false
	var source_state := WState.get_state_context(context)
	var target_value = target_property.get_property(source_state)
	for comparison_type in compare_values.keys():
		var value = compare_values[comparison_type]
		if not typeof(target_value) == typeof(value):
			return false
		if comparison_type == ComparisonType.EQUALS:
			if not target_value == value:
				return false
		if comparison_type == ComparisonType.GREATER_THAN:
			if not target_value > value:
				return false
		if comparison_type == ComparisonType.LESS_THAN:
			if not target_value < value:
				return false
	return true
