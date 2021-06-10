extends MarginContainer
class_name ParameterGroup

export (Array, NodePath) var param_containers

var parameters_affected := []

signal changed_property(property, value)

func _ready():
	for path in param_containers:
		var node : Node = get_node(path)
		for child in node.get_children():
			if child is BHPropertySetter:
				child.connect("property_changed", self, "_property_changed")
				parameters_affected.append(child.property)


func _property_changed(property : String, value):
	if property == "": return
	emit_signal("changed_property", property, value)
