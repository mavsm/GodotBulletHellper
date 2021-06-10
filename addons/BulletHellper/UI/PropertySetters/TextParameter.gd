extends BHPropertySetter

var text_entry : LineEdit

func _ready():
	text_entry = $LineEdit
	text_entry.connect("text_changed", self, "_on_text_changed")

func _on_text_changed(new_text):
	if property == "": return
	var new_val : float = float(new_text)
	emit_signal("property_changed", property, new_val)

func set_setter(value):
	if value is float or value is int:
		text_entry.text = str(value)
