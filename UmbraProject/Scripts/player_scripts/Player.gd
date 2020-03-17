extends KinematicBody2D
#class_name KinematicMoviment
# pause is 7
signal game_pause

const UP: = Vector2(0, -1)

onready var double_tap_timer: Timer = $DoubleTap
onready var damage_shape: CollisionShape2D = $Player_Damaged_Area/CollisionShape2D
onready var collision_shape: CollisionShape2D = $CollisionShape2D 
onready var attack_pos: Position2D = $AttackPos
onready var anim: = $Anim
onready var sprite: Sprite = $Sprite
# Aqui eu dou um preload na cena do atk , gosto de instancia-lá ela contem um timer de .5 que da queuefree
# Ai o inimigo que foi atingido que processa o dano e algum som que for tocar
onready var PRE_ATTACK: = preload("res://Scenes/AttackArea.tscn")

# Todas As actions fica na func Input

var strong_attack
var medium_attack
var dodge_input
var _crouch 
var jump_input 
var jump_pressed 
var jump_released 
var can_attack: = true 
var can_air_attack = true # Verificação Se Pode Atacar No Ar e Verificando Se Está Atacando No Ar
var jump_attacking = false # Verificação Se Está Atacando No Ar
# Movement.x and jump
signal input_changed # Esse sinal ainda não sei se pode ser util mas deixo ele aqui caso seja

export var run_default_max_vel: = 520 # Limite De Velocidade Max Quando corre
export var default_max_velocity: = 300 # Limite de velocidade quando anda
var acceleration: = 2000
var slowdown: = 1800
var gravity_acceleration: = 4000
var fall_velocity: = 600
var jump_velocity: = -1250
var jump_force_factor: = 4
var max_current_velocity: = 0.0
var input_direction: = Vector2()
var last_input_direction: = Vector2()
var target_velocity: = 0.0
var current_velocity: = Vector2()
var running = false 
var touchable: = true
var jumping = false
var _can_move = true
var _can_run = true
var _attacking = false
var _tap = 0
var right_input = float(Input.is_action_pressed("input_right"))
var left_input = float(Input.is_action_pressed("input_left"))
var _released_input_right
var _released_input_left
var _dash_run = -1
var _just_input_left
var _just_input_right

func _ready() -> void:
	randomize()
	$Player_Damaged_Area.connect("impulse", self, "_on_area_impulse")
	$Player_Damaged_Area.add_to_group("player")
	max_current_velocity = default_max_velocity
	double_tap_timer.connect("timeout", self, "_on_DoubleTap_timeout")
	

func _input(event: InputEvent) -> void:
	medium_attack = Input.is_action_pressed("medium_attack")
#	medium_attack = int(Input.is_action_pressed("medium_attack"))
	strong_attack = int(Input.is_action_pressed("strong_attack"))
	
	_released_input_left = int(Input.is_action_just_released("input_left"))
	_released_input_right = int(Input.is_action_just_released("input_right"))
	_just_input_left = int(Input.is_action_just_pressed("input_left"))
	_just_input_right = int(Input.is_action_just_pressed("input_right"))
	_tap_ammount(run_default_max_vel)
	
	if is_on_floor() :
		_crouch = int(Input.is_action_pressed("input_crouch"))
	dodge_input = int(Input.is_action_pressed("dodge_input"))
	jump_input = int(Input.is_action_pressed("input_jump"))
	jump_pressed = int(Input.is_action_just_pressed("input_jump"))
	jump_released = int(Input.is_action_just_released("input_jump"))
func _unhandled_input(event: InputEvent) -> void:
	_tap_ammount(max_current_velocity)
func _on_area_impulse(): # Pretendo usar isso em um futuro proximo para quando o player for hitado
	current_velocity.y = jump_velocity

func _process(delta: float) -> void:
	if !touchable:
		$Player_Damaged_Area.monitorable = false
		$Player_Damaged_Area.monitoring = false
		$Player_Damaged_Area/CollisionShape2D.disabled = true
	else:
		$Player_Damaged_Area/CollisionShape2D.disabled = false
		$Player_Damaged_Area.monitoring = true
		$Player_Damaged_Area.monitorable = true
		
	if !_can_move : return
		
	if input_direction and input_direction != last_input_direction:# n sei pq ta aqui
		emit_signal("input_changed")
	
func _physics_process(delta: float) -> void:
	attacking()
	right_input = float(Input.is_action_pressed("input_right"))
	left_input = float(Input.is_action_pressed("input_left"))
	
	input_direction.x = right_input - left_input 
				
	h_movement(delta)
	v_movement(delta)
	move_and_slide(current_velocity, UP)
	
func attacking() -> void : 
	if is_on_floor() and can_attack:
		
		if _crouch:
			if medium_attack and can_attack:
				_attacking = true
				anim.play("crouch_attack")
				can_attack = false
				_attack_changed(Vector2(60, 28), Vector2(50, 20), .3)
				yield(anim,"animation_finished")
				_attacking = false
				can_attack = true
			if strong_attack and can_attack:
#				_attacking = true
				_attack_changed(Vector2(60, 2), Vector2(20, 50), .5)
				
				
		else:
			if medium_attack and can_attack and !_crouch:
				_attacking = true 
				can_attack = false
				anim.play("attack")
				_attack_changed(Vector2(50, 0), Vector2(32, 37), .3)
				yield(anim,"animation_finished")
				_attacking = false
				can_attack = true
			
	if !is_on_floor() and Input.is_action_pressed("medium_attack"): # Jump Attack
		if Input.is_action_pressed("medium_attack") and can_air_attack:
				can_air_attack = false
				_attack_changed(Vector2(50, -10), Vector2(32, 50), .3)
				yield(get_tree().create_timer(.7),"timeout")
				can_air_attack = true
	
func _attack_changed(position_vector: Vector2,vector_pos: Vector2, duration:float):
	# Essa func é a que criei pra facilitar "moldar" o shape e sua posição
	var attack_area = PRE_ATTACK.instance()
	add_child(attack_area)
	attack_pos.position.y = position_vector.y
	if last_input_direction.x == 1:
		attack_pos.position.x = position_vector.x
	else:
		attack_pos.position.x = -position_vector.x
	attack_area.get_child(0).shape.extents = vector_pos
	attack_area.position = attack_pos.position
	yield(get_tree().create_timer(duration), "timeout")
	attack_area.queue_free()
	
func v_movement(delta) -> void :
	var smooth_factor = 0.5
	if jump_input:
		jumping = true
	
	if is_on_floor():
		jumping = false
		if _crouch :
			if !_attacking:
				anim.play("crouch")
			
				current_velocity.x = 0
				damage_shape.shape.extents = Vector2(19, 25)
				damage_shape.position.y = 33.533
		else:
			damage_shape.shape.extents = Vector2(19, 40)
			damage_shape.position.y = 14.533

	
	if not medium_attack :
		if is_on_floor() :
			current_velocity.y = 0
			if jump_pressed and !jumping :
				current_velocity.y = jump_velocity
			elif jump_released and current_velocity.y < 0 :
				current_velocity.y *= smooth_factor
		else:
			if last_input_direction.x == 1 :
				sprite.flip_h = false
				
			if last_input_direction.x == -1 :
				sprite.flip_h = true
				
			if can_air_attack:
				anim.play("jump")

	if is_on_ceiling():
		current_velocity.y = 0
	
	var variation = gravity_acceleration * delta
	
	if not jump_input and current_velocity.y < 0 :
		variation = gravity_acceleration * delta * jump_force_factor
		
	current_velocity.y = begin(current_velocity.y, fall_velocity, variation )
	
func h_movement(delta) -> void :
	var flip_last_input 
	
	if !_can_move : current_velocity.x = 0
	
	if last_input_direction.x == 1:
		flip_last_input = false
	else:
		flip_last_input = true
	
	if _attacking :
		current_velocity.x = 0 
		return
	
	if _crouch: current_velocity.x = 0
	
	if last_input_direction.x == 1 :
		$CollisionShape2D.position.x = 5.000
		$Player_Damaged_Area/CollisionShape2D.position.x = 4.561
	else: 
		$Player_Damaged_Area/CollisionShape2D.position.x = -4.561
		$CollisionShape2D.position.x = -5.000
	
	if medium_attack and is_on_floor():
		anim.animation_get_next("attack")
		return
		
	if _tap == 2:
		if last_input_direction.x == 1:
			max_current_velocity = 20000
		if last_input_direction.x == -1 :
			max_current_velocity = -20000
	if _tap != 2:
		max_current_velocity = 300
		
	if right_input or left_input:
		
		if input_direction.x == 0 and not medium_attack and is_on_floor() :
			anim.play("idle")
		
		if input_direction.x != 0 and is_on_floor() :
			anim.play("run")
		
		sprite.flip_h = flip_last_input
		
		if input_direction :
			last_input_direction = input_direction
	
			if target_velocity != max_current_velocity:
				target_velocity = max_current_velocity
		else:
			target_velocity = 0
	
		var variation = slowdown * delta
	
		if input_direction:
			variation = acceleration * delta

		current_velocity.x = (
					begin(current_velocity.x,
					 target_velocity * 
					input_direction.x,
					 variation )
					)
		sprite.flip_h = flip_last_input
		
	else:
		if input_direction.x == 0 and not medium_attack and is_on_floor() :
			anim.play("idle")
			current_velocity.x = 0
#		current_velocity.x = 0
	
func begin(current_val, target_val, variation) -> float :
	var difference = target_val - current_val
	
	if difference > variation :
		return current_val + variation
	
	if difference < -variation :
		return current_val - variation
	
	return target_val
	
func _on_DoubleTap_timeout():
	if _tap == 1:
		_tap = 0
		print("== 1")
	if _tap == 2:
		_tap = 2
		
	
func _tap_ammount(run_velocity: float)
	if _tap == 1 and input_direction.x != 0:
		_tap == 2
		print("+")
	if input_direction.x != 0 :
		_tap = 1
		double_tap_timer.start()
		return
