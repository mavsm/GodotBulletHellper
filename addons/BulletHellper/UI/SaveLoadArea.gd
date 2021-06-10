extends Control

signal pattern_loaded(pattern)

var save_path_input : LineEdit
var save_path := ""
var root_pattern : BulletHellperPattern
var packed_root_scene := PackedScene.new()

func _ready():
	save_path_input = $SavePath
	save_path_input.connect("text_changed", self, "_on_set_path")
	save_path_input.text = "res://Patterns/NewPattern.tscn"
	save_path = save_path_input.text
	
	$SaveButton.connect("pressed", self, "_save")
	$LoadButton.connect("pressed", self, "_load")

func _save():
	print("Saving resource! Path ", save_path)
	if save_path == "" or save_path == "res://.tscn": return
	if not root_pattern: return
	packed_root_scene.pack(root_pattern)
	ResourceSaver.save(save_path, packed_root_scene)

func _load():
	print("Attempting to load resource! ", save_path)
	if not ResourceLoader.exists(save_path):
		push_warning("File " + save_path + " does not exist!")
		return
	var loaded_pattern = ResourceLoader.load(save_path)
	emit_signal("pattern_loaded", loaded_pattern)

func _on_set_path(new_path : String):
	var updated := false
	if not new_path.begins_with("res://"):
		updated = true
		new_path = "res://"+new_path
	if not new_path.ends_with(".tscn"):
		updated = true
		new_path = new_path+".tscn"
	save_path = new_path
