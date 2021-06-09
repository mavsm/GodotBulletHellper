extends Button

var popup_window : Control
var popup_pos : Position2D

func _ready():
	if not $Control: return
	if not toggle_mode: toggle_mode = true
	popup_window = $Control
	popup_pos = $PopupPos
	_toggled(false)
	get_parent().connect("visibility_changed", self, "_on_parent_vis_changed")
	

func _on_parent_vis_changed():
	popup_window.set_as_toplevel(get_parent().visible && popup_window.visible)

func _toggled(button_pressed):
	if button_pressed:
		self.text = "Hide"
		popup_window.show()
		popup_window.set_as_toplevel(true)
		popup_window.rect_global_position = popup_pos.global_position
	else:
		self.text = "Show"
		popup_window.hide()
		popup_window.set_as_toplevel(false)


func _draw():
	if popup_window.visible:
		popup_window.rect_global_position = popup_pos.global_position
		
