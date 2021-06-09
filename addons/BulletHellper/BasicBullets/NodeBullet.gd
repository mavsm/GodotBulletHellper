extends Node2D

export var starting_speed : float
export var direction := Vector2(0,1)
export var radius := 9.0

var init_col_radius : float

var acceleration : float = 0.0
var speed : float
var lifetime : float
var check_boundary_time : float
var spent_time : float

var use_gradient : bool = false
var color_gradient : Gradient

var target_scale : float = 1.0

var grazed := false
var died := false

#Setup bullets info based on shell settings
func setup(shell : BulletShell):
	starting_speed = shell.speed
	speed = starting_speed
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

func move_bullet(delta):
	rotation = -direction.angle_to(Vector2(0, 1))
	
	position += direction*speed*delta
	speed = speed + acceleration*delta
	
	spent_time += delta
	
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
		modulate = color_gradient.interpolate(spent_time/lifetime)

func _out_of_bounds():
	_die()

func _grazed():
	grazed = true

func _die():
	if died : return
	died = true
	get_parent().remove_child(self)
	queue_free()
