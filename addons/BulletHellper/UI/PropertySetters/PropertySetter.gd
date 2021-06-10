extends Node
class_name BHPropertySetter
#Base for all types of setters for different properties and value types

export (String) var property

signal property_changed(property, value)


func _set_property(property, value):
	if property == self.property:
		set_setter(value)

#virtual function
func set_setter(value):
	pass
