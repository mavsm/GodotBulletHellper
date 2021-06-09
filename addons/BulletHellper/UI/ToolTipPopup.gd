extends Control

export (Vector2) var offset

var label : Label

func _ready():
	label = $Label
	disappear()


func appear(position : Vector2, tip : String):
	rect_global_position = position + offset
	label.text = tip
	rect_size = Vector2(0, 0)
	show()


func disappear():
	hide()
