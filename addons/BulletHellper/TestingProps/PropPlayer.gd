extends Node2D

#Simple prop player that follows the mouse and registers itself to the BHPatternManager

export var graze_radius := 15
export var hitbox_radius := 2
export (PackedScene) var prop_bomb

var graze_label : Label
var graze_count := 0


func _ready():
	graze_label = $Label
	BHPatternManager.bullet_target = self
	BHPatternManager.target_graze_radius = graze_radius
	BHPatternManager.target_radius = hitbox_radius

func _physics_process(delta):
	global_position = get_global_mouse_position()

func _unhandled_key_input(event):
	if event.pressed and event.scancode == KEY_CONTROL and not event.echo:
		if prop_bomb:
			var bomb = prop_bomb.instance()
			bomb.position = position
			get_parent().add_child(bomb)

func grazed():
	graze_count += 1
	graze_label.text = str(graze_count)

func on_hit():
	pass
