extends KinematicBody2D

var mouse_position
var UP = Vector2(0, -1)
var vel = 500
var dir = Vector2()
var gravity = 100
var _hooked = false
var jump_vel = 700
var raycast_enable = false 
var _can_hook = true

func _ready():
	$HookShot.connect("took_down", self, "_on_TookDown")
	add_to_group("player")
	

func _physics_process(delta: float) -> void:
	get_node("HookShot")._hook_shot(delta)
	
func _on_TookDown() -> void :
	print("caiu")
	
			
		
