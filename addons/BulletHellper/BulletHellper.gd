tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton('BHPatternManager', "res://addons/BulletHellper/Source/PatternManager.gd")

