extends Area2D

var dir 
var _velocity = 650

onready var anim = $Anim

func _ready():
	anim.play("idle")
	
	if get_parent().has_node("Player"): # Aqui eu simplesmente poderia ter usado Sign() mas eu não tinha conhecimento sobre isso ainda
		
		if get_parent().get_node("Player").last_input_direction.x == 1 :
			dir = 1
			$Sprite.flip_h = true
		elif get_parent().get_node("Player").last_input_direction.x == 0 :
			dir = 1
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
			dir = -1
	add_to_group("fireball")
	
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func _physics_process(delta: float) -> void:
	move_local_x( dir * _velocity * delta)
	
func _on_area_entered(area):
	
	pass

func _on_area_exited(area):
	
	pass

func _on_screen_exited():
	queue_free()
