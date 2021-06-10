tool
extends EditorPlugin

# Script that initializes the plugin Singleton

func _enter_tree():
	add_autoload_singleton('BHPatternManager', "res://addons/BulletHellper/Source/PatternManager.gd")

