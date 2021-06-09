extends CanvasLayer

export (bool) var log_debug = false
export (NodePath) var root_pattern_path
export (PackedScene) var pattern_scene

var current_pattern : BulletPattern
var root_pattern : BulletPattern

var optimization_bullet_count : Label
var optimization_fps : Label

var pattern_reset_pos : Vector2

#List of patterns in this scene
var patterns := []
#List of parameters that are changeable
var parameter_list := []

func _ready():
	current_pattern = get_node(root_pattern_path)
	root_pattern = get_node(root_pattern_path)
	pattern_reset_pos = root_pattern.position
	patterns = [current_pattern]
	set_property_setters()
	
	set_process_unhandled_input(false)
	
	optimization_bullet_count = $UIContainer/Optimization/BulletsOnScreen
	optimization_fps = $UIContainer/Optimization/FPS
	
	$UIContainer/Parameters/BasicParameters.connect("changed_property", self, "_on_property_changed")
	parameter_list += $UIContainer/Parameters/BasicParameters.parameters_affected
	$UIContainer/Parameters/DirectionParams.connect("changed_property", self, "_on_property_changed")
	parameter_list += $UIContainer/Parameters/DirectionParams.parameters_affected
	$UIContainer/Parameters/BulletParams.connect("changed_property", self, "_on_property_changed")
	parameter_list += $UIContainer/Parameters/BulletParams.parameters_affected
	$UIContainer/Parameters/PatternControls.connect("changed_property", self, "_on_property_changed")
	parameter_list += $UIContainer/Parameters/PatternControls.parameters_affected
	
	print(parameter_list)
	$SaveLoadArea.root_pattern = root_pattern

# Used to constantly update optimization data
func _process(delta):
	if(BHPatternManager.bullet_container):
		optimization_bullet_count.text = String(BHPatternManager.bullet_container.get_child_count())
	else: optimization_bullet_count.text = ""
	optimization_bullet_count.text += " Bullets"
	optimization_fps.text = String(Engine.get_frames_per_second())
	optimization_fps.text += " FPS"


#Signal callbacks and helper functions
func _on_enable_pressed():
	if root_pattern.shooting:
		root_pattern.disable()
	else:
		root_pattern.enable()

func _reset_pattern_pos():
	if current_pattern == root_pattern:
		current_pattern.position = pattern_reset_pos
	else:
		current_pattern.position = root_pattern.to_local(pattern_reset_pos)
	get_parent().update()

func _on_move_toggled(toggled):
	set_process_unhandled_input(toggled)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			set_current_position(BHPatternManager.get_global_mouse_position())

func set_current_position(pos : Vector2):
	current_pattern.global_position = pos
	get_parent().update()

func add_pattern():
	var new_pattern : BulletPattern = pattern_scene.instance()
	# We need to reset this dict here or this new pattern
	#  will share it with the original for some reason
	new_pattern.shell_settings = {}
	root_pattern.add_child(new_pattern, true)
	new_pattern.set_owner(root_pattern)
	patterns.append(new_pattern)

func duplicate_pattern():
	add_pattern()
	var added_pattern = patterns[patterns.size()-1]
	for property in parameter_list:
		if property == "name": continue
		var value = current_pattern.get(property)
		if value is Reference:
			added_pattern.set(property, value.duplicate(true))
		else:
			added_pattern.set(property, value)

func select_pattern(idx):
	current_pattern = patterns[idx]
	get_parent().update()
	set_property_setters()

func remove_pattern(idx : int = patterns.size()-1):
	var removed_pattern = patterns[idx]
	patterns.remove(idx)
	root_pattern.remove_child(removed_pattern)
	removed_pattern.queue_free()

func _on_load_pattern(pattern : PackedScene):
	get_parent().remove_child(root_pattern)
	root_pattern.queue_free()
	root_pattern = pattern.instance()
	get_parent().add_child(root_pattern)
	get_parent().pattern = root_pattern
	current_pattern = root_pattern
	
	var num_of_patterns := 1
	patterns = [root_pattern]
	for child in root_pattern.get_children():
		if child is BulletPattern:
			num_of_patterns+=1
			patterns.append(child)
	$UIContainer/Parameters/PatternControls.reset(num_of_patterns)
	$SaveLoadArea.root_pattern = root_pattern


func set_property_setters():
	for property in parameter_list:
		var value = current_pattern.get(property)
		get_tree().call_group("PropertySetters", "_set_property", property, value)


#Have a given property change reflect on the pattern
func _on_property_changed(property : String, value):
	if(log_debug): printt("Setting",property, value)
	var prop_name := property if not property.count(".") > 0 else property.split(".")[0]
	if not prop_name in current_pattern:
		push_warning(property +" is not a  property in current pattern!") 
		return
	
	current_pattern.set(property, value)
