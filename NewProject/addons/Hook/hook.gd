extends Node2D

signal took_down

export var _hook_cooldown = float(1)

var _old_body = null
var _special_input
var _release_special_input
var _hooked
var _hook_fall
var _can_hook = true

var _CdTimer = Timer.new()
var _shape = CollisionShape2D.new()
var _shape_type = RectangleShape2D.new()
var _ray_hook = RayCast2D.new()
var _line2d = Line2D.new()
var _area2d = Area2D.new()

var _last_dir = Vector2()
var _dir
var _up_l_stick_input 
var _down_l_stick_input
var _point

func _ready() -> void:
	if get_parent().is_connected("took_down", self, "_on_TookDown"):
		print("yes")
	get_parent().add_to_group("Player")
	
	if !get_parent().has_node("CollisionShape2D"):
		push_error("This node needs to have a parent with a shape")
	add_child(_area2d)
	add_child(_ray_hook)
	add_child(_line2d)
	add_child(_CdTimer)
	
	_CdTimer.autostart = false
	_CdTimer.wait_time = _hook_cooldown
	_CdTimer.connect("timeout", self, "_on_CdTimerTimeout")
	
	_ray_hook.cast_to.y = 0
	_ray_hook.enabled = true
	_ray_hook.exclude_parent = true
	_ray_hook.add_exception(get_parent())
	_shape_type.extents = get_parent().get_node("CollisionShape2D").shape.extents + Vector2(5, 5)
	_shape.shape = _shape_type
	
	_area2d.add_child(_shape)
	_area2d.connect("area_entered", self, "_on_AreaEntered")
	_area2d.connect("body_entered", self, "_on_BodyEntered")

func _on_CdTimerTimeout() -> void:
	if !_old_body == null: 
		_can_hook = true
		_hook_fall = false
		_old_body = null
	
func _on_BodyEntered(body) -> void:
	if !body.is_in_group("Player"):
		_old_body = body
		emit_signal("took_down")
		_hook_reset()
		
func _on_AreaEntered(area) -> void :
	print("area")
	
func _input(event: InputEvent) -> void:
	_down_l_stick_input = Input.is_action_pressed("down_left_axis")
	_up_l_stick_input = Input.is_action_pressed("up_left_axis")
	
	_special_input = Input.is_action_pressed("special_input")
	_release_special_input = Input.is_action_just_released("special_input")
	
func _draw() -> void:
	if _special_input:
		draw_line(global_position, _ray_hook.cast_to, Color(1,0,0))
		update()
	
func _hook_shot(delta):
	if !_can_hook or _hook_fall:
		pass
	
	var translate_vel_to_hook_point = 1500
	
	if !_ray_hook.get_collision_point() == Vector2(0, 0):
		_point = _ray_hook.get_collision_point()
	
	if _special_input :
		_ray_hook.enabled = true
		_hooked = true
		if _up_l_stick_input:
			_ray_hook.rotation += .05
		if _down_l_stick_input:
			_ray_hook.rotation -= .05
		_ray_hook.cast_to.x = 500
			
	if _release_special_input and !_ray_hook.get_collision_point() == Vector2(0, 0) and _ray_hook.is_colliding():
		var _ref = (_point - get_parent().global_position).normalized() * translate_vel_to_hook_point * delta
		get_parent().move_and_collide(_ref)
		_line2d.clear_points()
		
func _hook_reset() -> void:
	_hook_fall = true
	_ray_hook.enabled = false
	_ray_hook.cast_to.x = 0
	_hooked = false
	_can_hook = false
	if !_old_body == null :
		_CdTimer.start()
	
