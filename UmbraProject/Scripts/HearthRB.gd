extends RigidBody2D

var dir = 1
var touchable = true
var gravity = 1
var is_on_floor = false

func _ready() -> void:
	
	add_to_group("hearth")
	
	$Timer.connect("timeout", self, "_on_timer_timeout")
	$Timer.start()
	
	connect("body_entered", self, "_on_body_entered")

func _physics_process(delta: float) -> void:
	
	if !touchable:
		$CollisionShape2D.disabled = true
	
	move_local_x(dir)
	move_local_y(gravity)
	
func _on_timer_timeout():
	if is_on_floor :
		return
	
	if dir == 1:
		dir = -1
	else:
		dir = 1
		
	$Timer.start()
	
	if !touchable:
		queue_free()

func _picked():
	$sprite.visible = false
	touchable = false
	$pick.play()
	
func _on_body_entered(body):
	
	if body.is_in_group("wall"):
		is_on_floor = true
		gravity = 0
		dir = 0

