extends BHPropertySetter

export (String) var bullet_scenes_folder := "res://addons/BulletHellper/BasicBullets/"

var bullet_scenes : Array = []
var bullet_names : Array = []

func _ready():
	_set_bullet_scenes()
	for idx in range(bullet_names.size()):
		$OptionButton.add_item(bullet_names[idx], idx)
	$OptionButton.select(0)
	$OptionButton.connect("item_selected", self, "_on_item_selected")

func _set_bullet_scenes():
	var dir := Directory.new()
	dir.open(bullet_scenes_folder)
	dir.list_dir_begin()
	
	var file := dir.get_next()
	while file != "":
		if not dir.current_is_dir() and file.ends_with("Bullet.tscn"):
			bullet_scenes.append(load(bullet_scenes_folder + file))
			bullet_names.append(file.replace("Bullet.tscn", "").to_upper())
		file = dir.get_next()
	
	dir.list_dir_end()


func _on_item_selected(item : int):
	emit_signal("property_changed", property, bullet_scenes[item])

func set_setter(value):
	if value is PackedScene:
		$OptionButton.selected = bullet_scenes.find(value)
