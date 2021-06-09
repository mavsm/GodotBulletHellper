extends HBoxContainer

signal select_pattern(idx)
signal add_pattern()
signal remove_pattern(idx)

var buttons_num := 1
var pattern_buttons := []

var add_button:Button
var remove_button:Button

var selected_idx := 0

func _ready():
	pattern_buttons.append($Button)
	add_button = $AddButton
	remove_button = $RemoveButton
	
	$Button.connect("pressed", self, "_on_pressed_button", [0])

func _on_pressed_button(button_idx):
	selected_idx = button_idx
	for idx in range(pattern_buttons.size()):
		if idx == button_idx:
			pattern_buttons[button_idx].pressed = true
			continue
		pattern_buttons[idx].pressed = false
	emit_signal("select_pattern", button_idx)

func _remove_pattern(idx : int):
	var removed_button = pattern_buttons[idx]
	pattern_buttons.remove(idx)
	remove_child(removed_button)
	removed_button.queue_free()
	if selected_idx == idx:
		pattern_buttons[selected_idx-1].pressed = true
		_on_pressed_button(selected_idx-1)
	buttons_num -= 1
	if pattern_buttons.size() <= 1:
		remove_button.disabled = true

func remove_pattern_button(idx := buttons_num-1):
	_remove_pattern(idx)
	emit_signal("remove_pattern", idx)

func remove_selected_button():
	remove_pattern_button(selected_idx)
	for next_idxs in range(selected_idx+1, pattern_buttons.size()):
		pattern_buttons[next_idxs].text = str(next_idxs)
		pattern_buttons[next_idxs].disconnect("pressed", self, "_on_pressed_button")
		pattern_buttons[next_idxs].connect("pressed", self, "_on_pressed_button", [next_idxs])

func _add_pattern():
	var new_button : Button = Button.new()
	new_button.toggle_mode = true
	new_button.rect_min_size = Vector2(20, 20)
	new_button.text = str(buttons_num)
	buttons_num +=1
	add_child(new_button)
	pattern_buttons.append(new_button)
	if pattern_buttons.size() > 1:
		remove_button.disabled = false
	
	new_button.connect("pressed", self, "_on_pressed_button", [buttons_num-1])
	

func add_pattern_button():
	_add_pattern()
	
	emit_signal("add_pattern")

func _reset(num_of_patterns : int):
	for idx in range(pattern_buttons.size()-1, 0, -1):
		_remove_pattern(idx)
	for idx in range(num_of_patterns-1):
		_add_pattern()
	
	_on_pressed_button(0)
