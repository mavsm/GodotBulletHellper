extends HBoxContainer

export (Array, NodePath) var hideable_controls

var controls := []

func _ready():
	$Button.connect("toggled", self, "_on_toggled")
	
	for path in hideable_controls:
		controls.append(get_node(path))
	
	_on_toggled(true)

func _on_toggled(toggled):
	$Button.pressed = toggled
	for control in controls:
		control.visible = toggled
	
	$Button.text = "Hide" if toggled else "Show"
