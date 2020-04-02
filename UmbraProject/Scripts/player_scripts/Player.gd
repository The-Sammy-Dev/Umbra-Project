extends KinematicBody2D
class_name KinematicMoviment # vou passar a mecanica do hook shot pro script do irmão e na irmã terá a mecanica do dash
# pause is 7
signal game_pause

const UP: = Vector2(0, -1)

onready var _camera2d: Camera2D = $Camera2D
onready var _camera_timer: Timer = $Camera2D/CameraTimer
onready var _collision_shape: CollisionShape2D = $CollisionShape2D
onready var _ray_hook: RayCast2D = $RayHook
onready var _smoke: Particles2D = $RunEffect
onready var double_tap_timer: Timer = $DoubleTap
onready var damage_shape: CollisionShape2D = $Player_Damaged_Area/CollisionShape2D
onready var collision_shape: CollisionShape2D = $CollisionShape2D 
onready var attack_pos: Position2D = $AttackPos
onready var anim: = $Anim
onready var sprite: Sprite = $Sprite
onready var anim_camera: AnimationPlayer = $CameraAnim
# Aqui eu dou um preload na cena do atk , gosto de instancia-lá e dou um queuefree em seguida
# Ai o inimigo que foi atingido que processa o dano e algum som que for tocar
onready var PRE_ATTACK: = preload("res://Scenes/AttackArea.tscn")

# Essas actions tem que ficar setadas já para não dar null e não atrapalhar a movimentação
var right_input = float(Input.is_action_pressed("input_right"))
var left_input = float(Input.is_action_pressed("input_left"))
# Todas As actions fica na func Input
var _special_input
var _just_special_input
var _release_special_input
var strong_attack
var _released_crouch
var medium_attack
var _released_input_right
var dodge_input
var _just_input_left
var _just_input_right
var _released_input_left
var down_input
var _just_input_down
var _crouch 
var jump_input 
var jump_pressed 
var jump_released 
var can_attack: = true 
var can_air_attack = true # Verificação Se Pode Atacar No Ar e Verificando Se Está Atacando No Ar
var jump_attacking = false # Verificação Se Está Atacando No Ar
var _can_jump = true
# Movement.x and jump
signal input_changed # Esse sinal ainda não sei se pode ser util mas deixo ele aqui caso seja

export var run_default_max_vel: = 650 # Limite De Velocidade Max Quando corre
export var default_max_velocity: = 450 # Limite de velocidade quando anda
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
var _dash_run = -1
var _time_start
var _elapse_timer

# Hook var's
var hooked = false
var can_hook = true

func _ready() -> void:
	randomize()
	$Player_Damaged_Area.connect("impulse", self, "_on_area_impulse")
	$Player_Damaged_Area.add_to_group("player")
	max_current_velocity = default_max_velocity
	double_tap_timer.connect("timeout", self, "_on_DoubleTap_timeout")
	_camera_timer.connect("timeout", self, "_on_CameraTimer_timeout")

func _input(event: InputEvent) -> void:
	_special_input = int(Input.is_action_pressed("input_special"))
	_just_special_input = int(Input.is_action_just_pressed("input_special"))
	_release_special_input = int(Input.is_action_just_released("input_special"))
	medium_attack = Input.is_action_pressed("medium_attack")
	strong_attack = int(Input.is_action_pressed("strong_attack"))
	
	_released_input_left = int(Input.is_action_just_released("input_left"))
	_released_input_right = int(Input.is_action_just_released("input_right"))
	_just_input_left = int(Input.is_action_just_pressed("input_left"))
	_just_input_right = int(Input.is_action_just_pressed("input_right"))
	
	
	_just_input_down = int(Input.is_action_just_pressed("input_crouch"))
	_crouch = int(Input.is_action_pressed("input_crouch"))
	_released_crouch = int(Input.is_action_just_released("input_crouch"))
		
	dodge_input = int(Input.is_action_pressed("dodge_input"))
	jump_input = int(Input.is_action_pressed("input_jump"))
	jump_pressed = int(Input.is_action_just_pressed("input_jump"))
	jump_released = int(Input.is_action_just_released("input_jump"))
	
func _unhandled_input(event: InputEvent) -> void:
	_tap_ammount()
		 
func _on_area_impulse(): # Pretendo usar isso em um futuro proximo para quando o player for hitado
	current_velocity.y = jump_velocity

func _process(delta: float) -> void: # Coloquei a move da camera aqui, não sei se foi o melhor
	_camera_position() 
	
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
	get_node("HookShot")._hook_shot(delta)
	if hooked: return
	
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
			if strong_attack and can_attack: # Esse Ataque eu estava fazendo mas não consigo fazer sem uma animação pra me orientar 
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
	
func v_movement(delta) -> void :# Aqui tbm tem o input pra agachar
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
				_collision_shape.shape.extents = Vector2(19.086, 24.3)
				_collision_shape.position.y = 32.69
		else:
			damage_shape.shape.extents = Vector2(19, 40)
			damage_shape.position.y = 14.533
			_collision_shape.shape.extents = Vector2(19.086, 38.87)
			_collision_shape.position.y = 17.506
			
	if not medium_attack :
		if is_on_floor() :
			current_velocity.y = 0
			if _can_jump:
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
	
	if !_can_move : return
	
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
		
	if  running:
			if input_direction :
				last_input_direction = input_direction
		
				if target_velocity != run_default_max_vel:
					target_velocity = run_default_max_vel
			else:
				target_velocity = 0

	if !running:
		if input_direction :
				last_input_direction = input_direction
		
				if target_velocity != default_max_velocity:
					target_velocity = default_max_velocity
		else:
			target_velocity = 0
	
	if right_input or left_input: 
		
		if input_direction.x == 0 and not medium_attack and is_on_floor() :
			anim.play("idle")
		
		if input_direction.x != 0 and is_on_floor() :
			anim.play("run")
		
		sprite.flip_h = flip_last_input
		
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
		if sprite.flip_h :
			_smoke.process_material.direction.x = 1
			_smoke.position.x = 51.314
		else:
			_smoke.process_material.direction.x = -1
			_smoke.position.x = -31.249
	if input_direction.x == 0 and not medium_attack and is_on_floor() :
			anim.play("idle")
			current_velocity.x = 0

#func _hook_shot(delta):# Cara isso aqui, ta quase lá, muito quase
#	pass
#	var translate_vel_to_hook_point = 1500
#	var axis_value1 = Input.get_joy_axis(0, JOY_AXIS_0)
#	var axis_value2 = Input.get_joy_axis(0, JOY_AXIS_1)
#	var _dir = Vector2(stepify(axis_value1,.1), stepify(axis_value2,.1)).normalized()
#	var _point = _ray_hook.get_collision_point()
#	var _ref = (_point - global_position).normalized() * translate_vel_to_hook_point * delta
#	if _special_input:
#		hooked = true
#		_ray_hook.rotation = _dir.angle()
#		if !_ray_hook.is_colliding():
#			_ray_hook.cast_to.x += 5
#			_point = _ray_hook.get_collision_point()
#		if _ray_hook.is_colliding():
#
#			if _ray_hook.get_collider().is_class("StaticBody2D") :
#				print("haueh")
#			_point = _ray_hook.get_collision_point()
#	if _release_special_input:
#		$RayHook/Line2D.clear_points()
#		move_and_collide(_ref)
#
#		yield(get_tree().create_timer(1), "timeout")
#		hooked = false
#		_ray_hook.cast_to.x = 0
#	$RayHook/Line2D.add_point(_ray_hook.cast_to)
	
func begin(current_val, target_val, variation) -> float : # Aqui é pra fazer uma variação quando solta o botão da direção e ficar mais real
	var difference = target_val - current_val
	
	if difference > variation :
		return current_val + variation
	
	if difference < -variation :
		return current_val - variation
	
	return target_val
	
func _on_DoubleTap_timeout(): # Pra resetar o _tap
	_tap = 0
	
func _tap_ammount(): # Aqui é para o double tap da corrida
	if _just_input_right or _just_input_left:
		_tap += 1
		double_tap_timer.start()
		if _tap == 2:
			_tap == 2
			running = true
		else:
			running = false

func _camera_position(): 
	
	
	if is_on_floor():
		if _crouch:
			if _just_input_down:
				_camera_timer.start(3)
				
		else:
			_camera_timer.stop()
		
func _on_CameraTimer_timeout():
	_can_jump = false
	_can_move = false
	can_attack = false
	anim_camera.play("down_camera")
	yield(get_tree().create_timer(1),"timeout")
	anim_camera.play_backwards("down_camera")
	yield(get_tree().create_timer(1),"timeout")
	_can_jump = true
	_can_move = true
	can_attack = true
	
#	
	
	
