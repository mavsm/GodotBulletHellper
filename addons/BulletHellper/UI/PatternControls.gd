extends ParameterGroup

signal select_pattern(idx)
signal add_pattern()
signal duplicate_pattern()
signal remove_pattern(idx)

var delete_button : Button
var selector : Control


func _ready():
	selector = $VBoxContainer/PatternSelector
	delete_button = $VBoxContainer/HBoxContainer/Delete

func reset(num_of_patterns : int):
	selector._reset(num_of_patterns)

func _on_add():
	emit_signal("add_pattern")

func _on_duplicate():
	emit_signal("duplicate_pattern")
	selector._add_pattern()

func _on_select(idx):
	delete_button.disabled = idx == 0
	emit_signal("select_pattern", idx)

func _on_remove_current():
	selector.remove_selected_button()

func _on_remove(idx : int):
	emit_signal("remove_pattern", idx)
