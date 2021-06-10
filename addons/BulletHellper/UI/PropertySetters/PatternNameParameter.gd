extends BHPropertySetter

var text_entry : LineEdit

func _ready():
	text_entry = $LineEdit
	text_entry.connect("text_changed", self, "_on_text_changed")

func _on_text_changed(new_text):
	if property == "": return
	emit_signal("property_changed", property, new_text)

func set_setter(value):
	if value is String:
		text_entry.text = value
