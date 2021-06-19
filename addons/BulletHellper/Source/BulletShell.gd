extends Reference
class_name BHBulletShell


var speed : float
var max_speed : float = 0.0
var lifetime : float = 3.0
var oob_check_time : float = 0.0
var acceleration : float = 0.0

var x_scale : float = 1.0
var y_scale : float = 1.0

var color := Color.white

var use_gradient := false
var gradient := Gradient.new()

var aim_individual_bullet := false

var angular_speed := 0.0
var max_angular_stray := 0.0

func _init(spd : float):
	speed = spd
	gradient = Gradient.new()
	gradient.set_color(0, Color.white)
	gradient.set_color(1, Color.white)

func set(property, value):
#	printt(property, value)
	if property == "gradient":
		if not value is Array or value.size() < 3:
			if value is Gradient:
				gradient = value
			return
		gradient.set_color(value[0], value[1])
		gradient.set_offset(value[0], value[2])
		return
	.set(property, value)

