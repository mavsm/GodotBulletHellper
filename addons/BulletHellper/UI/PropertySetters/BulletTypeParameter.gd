extends PropertySetter

export (Array, PackedScene) var bullet_scenes : Array


func _ready():
	$OptionButton.add_item("SIMPLE", 0)
	$OptionButton.add_item("BIG", 1)
	$OptionButton.add_item("SMALL", 2)
	$OptionButton.select(0)
	$OptionButton.connect("item_selected", self, "_on_item_selected")


func _on_item_selected(item : int):
	emit_signal("property_changed", property, bullet_scenes[item])

func set_setter(value):
	if value is PackedScene:
		$OptionButton.selected = bullet_scenes.find(value)
