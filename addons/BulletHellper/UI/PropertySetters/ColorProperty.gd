extends BHPropertySetter
class_name BHColorProperty

var color_picker : ColorPickerButton

func _ready():
	color_picker = $ColorPickerButton
	color_picker.connect("color_changed", self, "_on_color_changed")

func _on_color_changed(color:Color):
	emit_signal("property_changed", property, color)

func set_setter(value):
	if value is Color:
		color_picker.color = value
