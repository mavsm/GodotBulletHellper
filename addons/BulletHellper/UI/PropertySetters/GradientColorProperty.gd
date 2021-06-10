extends BHColorProperty

export var index = 0

var current_color := Color.white
var current_offset := 0.0

var text_entry : LineEdit

func _ready():
	text_entry = $LineEdit
	
	current_color = color_picker.color
	current_offset = float(index)
	
	text_entry.connect("text_changed", self, "_on_text_changed")


func _on_text_changed(text : String):
	current_offset = clamp(float(text), 0.0, 1.0)
	emit_signal("property_changed", property, [index, current_color, current_offset])
	

func _on_color_changed(color:Color):
	current_color = color
	emit_signal("property_changed", property, [index, color, current_offset])


func set_setter(value):
	if value is Gradient:
		color_picker.color = value.get_color(index)
