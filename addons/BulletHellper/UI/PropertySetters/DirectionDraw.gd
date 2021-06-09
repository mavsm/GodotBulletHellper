extends HSlider

export var direction_distance = 30.0

signal changed_direction(value)

const DEFAULT_DIR = Vector2(0, 1)

var direction := DEFAULT_DIR

var canvas : Control
var canvas_center : Vector2
var label : Label

func _ready():
	canvas = $MarginContainer/ColorRect
	canvas_center = canvas.rect_position + canvas.rect_size/2
	canvas_center += $MarginContainer.rect_position
	
	label = $MarginContainer/Label
	
	connect("value_changed", self, "_on_value_changed")

func _on_value_changed(value):
	direction = DEFAULT_DIR.rotated(deg2rad(value))
	label.text = String(value).pad_zeros(3) + " deg"
	emit_signal("changed_direction", direction)

func _draw():
	draw_line(canvas_center, canvas_center+direction_distance*direction, Color.black, 2)


func set_direction(value:Vector2):
	direction = value.normalized()
	var deg : int = int(rad2deg(direction.angle_to(DEFAULT_DIR)))
	if deg <= 0: deg = abs(deg)
	else: deg = 360 - deg
	label.text = str(deg).pad_zeros(3) + " deg"
	self.value = deg
	update()
