extends Node2D
"""
	This singleton keeps tabs most necessary knowledge of the bullet hell. It
	keeps track and informs the patterns of where the aim target (usually the
	player) is, as well keeping reference as to which bullet container the
	patterns should use.
	
	It also helps with simple collision detection (as using Godot's internal
	physics proved to cost too much with high bullet density), as well as
	keeping reference to the boundary which bullets die when they leave.
"""


const BOUNDARY_RECT := Rect2(-15,-15, 715,915)

var bullet_container : Node
var bullet_target : Node

#Used in collision calculations
var target_radius := 0.0
var target_graze_radius := 0.0

var extra_colliders := []

"""Registration functions"""

#Register the container which will contain all bullets as its children
func register_bullet_container(node : Node):
	bullet_container = node
#Register the target for patterns aimed shots
func register_bullet_target(node : Node):
	bullet_target = node
#Register and deregister colliders other than the target that may exist in the
#scene, such as bombs or obstacles
func register_other_collider(node : Node):
	extra_colliders.append(node)

func deregister_other_collider(node : Node):
	extra_colliders.erase(node)

"""General helper functions"""
func get_target_position()->Vector2:
	if bullet_target:
		return bullet_target.global_position
	return get_global_mouse_position()

"""Collision helper functions"""
func was_grazed(dist : float, radius : float)->bool:
	if dist < _get_min_target_graze_sqrd_dist(radius):
		if bullet_target:
			bullet_target.grazed()
		return true
	return false

func has_collided(dist : float, pos : Vector2, radius : float)->bool:
	for collider in extra_colliders:
		if collider.is_colliding(pos, radius): return true
	if dist < _get_min_target_sqrd_dist(radius):
		if bullet_target:
			bullet_target.on_hit()
		return true
	return false

func is_in_boundary(radius, pos):
	return BOUNDARY_RECT.grow(radius).has_point(pos)

func _get_min_target_graze_sqrd_dist(radius : float)->float:
	return pow(radius+target_graze_radius, 2)

func _get_min_target_sqrd_dist(radius : float)->float:
	return pow(radius+target_radius, 2)
