extends BHPropertySetter


func _ready():
	$OptionButton.add_item("LINEAR", 0)
	$OptionButton.add_item("ARCH", 1)
	$OptionButton.select(1)
	$OptionButton.connect("item_selected", self, "_on_item_selected")

func _on_item_selected(item):
	emit_signal("property_changed", property, item);

func set_setter(value):
	if value is int:
		$OptionButton.selected = value
