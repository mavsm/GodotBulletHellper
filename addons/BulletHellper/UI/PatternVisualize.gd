extends Node2D

const SELECTED_COLOR = Color.red
const UNSELECTED_COLOR = Color.darkcyan

var pattern : BulletHellperPattern
var UIManager


func _ready():
	BHPatternManager.register_bullet_container($BulletContainer)
	pattern = $BulletPattern
	UIManager = $UI


func _draw():
	draw_rect(BHPatternManager.BOUNDARY_RECT, Color.black, false)
	draw_cross(pattern.global_position, 10, UNSELECTED_COLOR)
	for child in pattern.get_children():
		if not child is BulletHellperPattern: continue
		draw_cross(child.global_position, 10, UNSELECTED_COLOR)
	draw_cross(UIManager.current_pattern.global_position, 20, SELECTED_COLOR)


func draw_cross(pos : Vector2, size : float, color := Color.red):
	draw_line(pos - Vector2(size/2, 0), pos + Vector2(size/2, 0), color)
	draw_line(pos - Vector2(0, size/2), pos + Vector2(0, size/2), color)
	

