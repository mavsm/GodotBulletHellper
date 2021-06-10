extends BHPropertySetter

func _ready():
	$DirectionSlider.connect("changed_direction", self, "_on_changed_direction")

func _on_changed_direction(value):
	emit_signal("property_changed", property, value)

func set_setter(value):
	if value is Vector2:
		$DirectionSlider.set_direction(value)
