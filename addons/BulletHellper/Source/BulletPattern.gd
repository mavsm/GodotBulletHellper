extends Node2D
class_name BulletHellperPattern

signal shot

const MIN_COOLDOWN = .05

enum ShotType{
	LINEAR,
	ARCH,
	STATIC_ARCH
}

# Bullet to be shot
export (PackedScene)        var bullet_scene
# Cooldown between shots
export (float)              var bullet_cooldown := 0.3 setget set_cooldown
# How much time should the pattern wait to fire initial wave
export (float)              var initial_wait_time := 0.0 setget set_initial_wait_cooldown
# Numbers of bullet in each shot
export (int)                var bullet_num := 1
# If greater than 0, each shot will wait that time to be shot, from the previous shot 
export (float)              var cooldown_between_bullets := 0.0 setget set_between_shot_cooldown
# Is each shot directed at the player?
export (bool)               var aiming_bullet := false
# If the shots are spread linearly or in an arch
export (ShotType)           var shot_type
# The spread size of the shot
export (float)              var spread := 0.0
# If true, each bullet will use the same direction before randomness is applied
export (bool)               var use_static_direction := false
# Direction of the shot
export (Vector2)            var direction := Vector2() setget set_direction
# How far away from the starting points should the bullet be?
export (float)              var position_offset := 0.0
# How far away from the starting points perpendicular to directioon should the bullet be?
export (float)              var perpendicular_offset := 0.0
# Is the spread rotating?
export (bool)               var is_rotating := false
# Rotating speed, in rads/sec, if the spread is rotating
export (float)              var rotating_speed := 0.5
# Randomize position slightly by proportional value
export (float)              var randomize_position := 0.0
# Randomize direction slightly by rotating by a max of angle provided
export (float)              var randomize_direction := 0.0
# Randomize position slightly parallel to direction by proportional value
export (float)              var randomize_parallel := 0.0
# Randomize position slightly perpendicular to direction by proportional value
export (float)              var randomize_perpendicular := 0.0
# Applies properties mentioned to bullets
export (Dictionary)         var shell_settings := {}

var shell : BHBulletShell = BHBulletShell.new(100.0)

var type : int
var bullet_container
var aim_target : Node = null

var current_rotation := 0.0

var shooting := false

var base_timer : Timer
var initial_wait_timer : Timer
var between_bullet_timer : Timer

var rotated_dir : Vector2

func _ready():
	base_timer = $Timer
	base_timer.wait_time = bullet_cooldown
	initial_wait_timer = $InitialWaitTimer
	if initial_wait_time > 0.0:
		initial_wait_timer.wait_time = initial_wait_time
	base_timer.connect("timeout", self, "_on_timer_timeout")
	between_bullet_timer = $BetweenShotTimer
	if cooldown_between_bullets > 0.0: between_bullet_timer.wait_time = cooldown_between_bullets
	
	setup_shell()
	
	set_physics_process(not aiming_bullet and is_rotating)
	
	if get_tree().current_scene == self:
		var testing_container := Node2D.new()
		add_child(testing_container)
		testing_container.global_position = Vector2()
		BHPatternManager.register_bullet_container(testing_container)
		enable()

func setup_shell():
	for property in shell_settings.keys():
		shell.set(property, shell_settings[property])


"""
*
 -- SETTERS AND GETTERS --
*
"""

func set(property : String, value):
	if property.count(".") > 0:
		var subproperties = property.split(".", true, 1)
		get(subproperties[0]).set(subproperties[1], value)
		if subproperties[0] == "shell":
			shell_settings[subproperties[1]] = shell.get(subproperties[1])
#			print(shell_settings)
		return
	if property == "name" and value == "":
		return
	.set(property, value)

func get(property : String):
	if property.count(".") > 0:
		var subproperties = property.split(".", true, 1)
		return get(subproperties[0]).get(subproperties[1])
	return .get(property)

func set_direction(new_dir : Vector2):
	direction = new_dir
	if shooting:
		rotated_dir = direction

func set_aim_target(new_target : Node):
	aim_target = new_target

func set_bullet_container(new_bullet_container : Node):
	bullet_container = new_bullet_container
	for child_pattern in get_children():
		if child_pattern is Timer: continue
		child_pattern.set_bullet_container(new_bullet_container)

func set_cooldown(new_cooldown : float):
	bullet_cooldown = new_cooldown
	if bullet_cooldown < MIN_COOLDOWN:
		bullet_cooldown = MIN_COOLDOWN
	if base_timer:
		base_timer.wait_time = bullet_cooldown

func set_between_shot_cooldown(new_cooldown : float):
	cooldown_between_bullets = new_cooldown
	if cooldown_between_bullets <= 0.0: return
	if between_bullet_timer: between_bullet_timer.wait_time = cooldown_between_bullets

func set_initial_wait_cooldown(new_cooldown : float):
	initial_wait_time = new_cooldown
	if initial_wait_time <= 0.0: return
	if initial_wait_timer: initial_wait_timer.wait_time = initial_wait_time


"""
*
 -- ENABLING/DISABLING --
*
"""


func disable():
	shooting = false
	base_timer.stop()
	base_timer.one_shot = true
	$InShotTimer.stop()
	
	for child_pattern in get_children():
		if not child_pattern.get_class() == self.get_class(): continue
		child_pattern.disable()


func enable():
	#We have to set bullet container here, as other nodes are expected to set
	#PatternManager's container on their ready functions
	if not bullet_container:
		self.bullet_container = BHPatternManager.bullet_container
	rotated_dir = direction
	
	shooting = true
	
	if initial_wait_time > 0:
		initial_wait_timer.start()
		yield(initial_wait_timer, "timeout")
	
	if not shooting: return
	_on_timer_timeout()
	base_timer.start()
	base_timer.one_shot = false
	
	for child_pattern in get_children():
		if child_pattern.has_method("enable"): #Enables all child patterns
			child_pattern.enable()


func _on_timer_timeout():
	if shooting:
		shoot_bullet(global_position)
		if is_rotating:
			rotated_dir = rotated_dir.rotated(deg2rad(rotating_speed))


"""
*
 -- BULLET SHOOTING/INSTANCING --
*
"""

#Change in-bullet params
func affect_bullet(bullet):
	if bullet.has_method("setup"):
		bullet.setup(shell)

func shoot_bullet( spawn_pos := Vector2.ZERO):
	if not bullet_scene:
		push_warning("Warning: Bullet Pattern missing bullet scene")
		return
	
	var direction : Vector2
	var perpendicular_dir : Vector2
	if aiming_bullet:
		var aim_position = BHPatternManager.get_target_position() if not aim_target else aim_target.global_position
		direction = (aim_position - spawn_pos).normalized()
	else:
		direction = self.rotated_dir.normalized()
	perpendicular_dir = direction.rotated(.5*PI)
	
	
	var offset : float
	var linear_offset : Vector2
	var static_direction := direction
	match shot_type:
		ShotType.LINEAR:
			offset = 0.0 if bullet_num <= 1 else spread/(bullet_num-1)
			linear_offset = perpendicular_dir*offset
			spawn_pos -= linear_offset*(bullet_num-1)/2.0
			
		ShotType.ARCH:
			var rad_spread = deg2rad(spread)
			offset = 0 if bullet_num <= 1 else rad_spread/(bullet_num-1) if rad_spread < 2*PI else rad_spread/bullet_num
			direction = direction.rotated(-offset*(bullet_num-1)/2)
		

	for i in range(bullet_num):
		var bullet_instance = bullet_scene.instance()
		var randomized_pos := Vector2()
		bullet_instance.direction = direction
		
		bullet_container.call_deferred("add_child", bullet_instance)
		
		match shot_type:
			ShotType.LINEAR:
				bullet_instance.position = spawn_pos + i*linear_offset
			ShotType.ARCH:
				bullet_instance.position = spawn_pos
				bullet_instance.direction = direction.rotated(offset*i)
				perpendicular_dir = bullet_instance.direction.rotated(.5*PI)
		
		if randomize_position != 0:
			randomized_pos.x = rand_range(-randomize_position, randomize_position)
			randomized_pos.y = rand_range(-randomize_position, randomize_position)
		if randomize_parallel != 0:
			var rand_offset = rand_range(-randomize_parallel, randomize_parallel)*bullet_instance.direction
			randomized_pos += rand_offset
		if randomize_perpendicular != 0:
			var rand_offset = rand_range(-randomize_perpendicular, randomize_perpendicular)*perpendicular_dir
			randomized_pos += rand_offset
		
		bullet_instance.position += bullet_instance.direction.normalized()*position_offset
		bullet_instance.position += perpendicular_dir*perpendicular_offset
		bullet_instance.position += randomized_pos
		
		if use_static_direction:
			bullet_instance.direction = static_direction
		
		if randomize_direction != 0:
			var randomized_rot := deg2rad(rand_range(-randomize_direction/2, randomize_direction/2))
			bullet_instance.direction = bullet_instance.direction.rotated(randomized_rot)
		
		affect_bullet(bullet_instance)
		
		if cooldown_between_bullets > 0.0:
			between_bullet_timer.start()
			yield(between_bullet_timer, "timeout")
		if not shooting: break
	
	emit_signal("shot")
