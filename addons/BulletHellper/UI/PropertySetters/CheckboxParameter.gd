extends BHPropertySetter

export (Array, NodePath) var controls_to_toggle

var toggled_controls : Array
var checkbox : CheckBox

func _ready():
	checkbox = $CheckBox
	checkbox.connect("toggled", self, "_on_toggled")
	toggled_controls = []
	if controls_to_toggle:
		for path in controls_to_toggle:
			toggled_controls.append(get_node(path))


func _on_toggled(value : bool):
	emit_signal("property_changed", property, value)
	if not toggled_controls.empty():
		for control in toggled_controls:
			control.visible = not control.visible

func set_setter(value):
	if value is bool:
		checkbox.pressed = value
