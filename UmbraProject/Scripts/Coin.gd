extends RigidBody2D
#Stay faz ela ficar parada
var UP = Vector2(0, -1)
var direction = Vector2(0, 0)
export var _Damp: float = 1.9
export var _bounce: = 100
export var _stay : bool 
export var _GravityScale: = 10
export var _Apply_impulse: Vector2 = Vector2(0, -10)
var touchable: bool = true

onready var shape_coin: = $CollisionShape2D

var initialPos = Vector2.ZERO

func _ready():
	add_to_group("coin")
	initialPos = self.global_position
	
	$Anim.play("idle")
	$del.connect("timeout", self, "_on_del_timeout")
	connect("body_entered", self, "_on_body_entered")
	
	physics_material_override.bounce = _bounce
	linear_damp = _Damp
	gravity_scale = _GravityScale
	
	if _stay:
		sleeping = true
	
func _on_del_timeout() -> void :
	queue_free()

func _process(delta: float) -> void:
	if !touchable:
		$CollisionShape2D.disabled = true
		pass

func _integrate_forces(state):
	state.angular_velocity = 0
	# pra ela parar de rotacionar e ficar sempre no meio, como é um rigidbody
	# se algo bater ela vai saltar pra outro lugar rotacionando
	# toda vez que for alterar a física de um rigidbody precisa ser no _integrate_forces e não no _process ou _physics_process
	

# o player é um body, então precisa ser nesse sinal de body entered
func _on_body_entered(body) :
	if body.is_in_group("player"):
		if !$pick_up.is_playing():
			$pick_up.play()
		print("player colidiu")
		$fall.stop()
		touchable = false
		$del.start()
		$Area2D/Anim.visible = false

func pick_coin():
	if !$pick_up.is_playing():
		$pick_up.play()
	print("player colidiu")
	$fall.stop()
	touchable = false
	$del.start()
	$Anim.visible = false
	
