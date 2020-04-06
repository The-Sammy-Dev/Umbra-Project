tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("HookShot", "Node2D", preload("hook.gd"), preload("res://addons/Hook/icon.png"))

func _exit_tree() -> void:
	remove_custom_type("HookShot")
	
