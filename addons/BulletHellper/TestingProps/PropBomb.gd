extends Node2D

var sprite : Sprite
var sprite_size : Vector2

func _ready():
	sprite = $icon
	sprite_size = sprite.get_rect().size
	BHPatternManager.register_other_collider(self)

var drawn : bool = false
func _process(delta):
	drawn = false

func get_current_rect()->Rect2:
	var rect = Rect2(position-(sprite_size*sprite.scale)/2.0, sprite_size*sprite.scale)
	return rect

func is_colliding(pos : Vector2, radius : float)->bool:
	return get_current_rect().grow(radius/2.0).has_point(pos)


func _die():
	BHPatternManager.deregister_other_collider(self)
	get_parent().remove_child(self)
	queue_free()
