extends Node2D
class_name BHBullet

export var starting_speed : float
export var direction := Vector2(0,1)
export var radius := 9.0

var init_col_radius : float

var acceleration : float = 0.0
var speed : float
var max_speed : float
var lifetime : float
var check_boundary_time : float
var spent_time : float

var use_gradient : bool = false
var color_gradient : Gradient

var target_scale : float = 1.0

var grazed := false
var died := false

var angular_speed := 0.0
var angular_stray := 0.0
var max_angular_stray := 0.0

#Setup bullets info based on shell settings
func setup(shell : BHBulletShell):
	if starting_speed == 0:
		starting_speed = shell.speed
	speed = starting_speed
	max_speed = shell.max_speed
	angular_speed = deg2rad(shell.angular_speed)
	max_angular_stray = deg2rad(shell.max_angular_stray)
	acceleration = shell.acceleration
	lifetime = shell.lifetime
	check_boundary_time = shell.oob_check_time
	use_gradient = shell.use_gradient
	if use_gradient:
		color_gradient = shell.gradient
		modulate = color_gradient.interpolate(0.0)
	else:
		modulate = shell.color
	if shell.aim_individual_bullet:
		direction = BHPatternManager.get_target_position() - position

func _ready():
	spent_time = 0.0
	direction = direction.normalized()


func _physics_process(delta):
	move_bullet(delta)
	check_collisions()

func move_bullet(delta):
	angular_stray += angular_speed*delta
	if max_angular_stray == 0 or abs(angular_stray) < abs(max_angular_stray):
		direction = direction.rotated(angular_speed*delta)
	rotation = -direction.angle_to(Vector2.UP)
	
	position += direction*speed*delta
	if max_speed == 0 or abs(speed) < abs(max_speed):
		speed = speed + acceleration*delta
	
	spent_time += delta

func check_collisions():
	var dist_sqrd_to_player = BHPatternManager.get_target_position().distance_squared_to(global_position)
	if not grazed and BHPatternManager.was_grazed(dist_sqrd_to_player, radius):
		_grazed()
	if BHPatternManager.has_collided(dist_sqrd_to_player, global_position, radius):
		_die()
	
	if spent_time > check_boundary_time and not BHPatternManager.is_in_boundary(radius, position):
		_out_of_bounds()
	
	if spent_time > lifetime:
		_die()
	
	if use_gradient:
		var time = lifetime if lifetime > 0 else 1
		modulate = color_gradient.interpolate(spent_time/time)

func _out_of_bounds():
	_die()

func _grazed():
	grazed = true

func _die():
	if died : return
	died = true
	get_parent().remove_child(self)
	queue_free()
