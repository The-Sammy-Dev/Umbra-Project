extends Node2D

var _special_input
var _release_special_input

var _ray_hook = RayCast2D.new()
var _line2d = Line2D.new()
func _input(event: InputEvent) -> void:
	_special_input 


func _hook_shot(delta):# Cara isso aqui, ta quase lá, muito quase
	var translate_vel_to_hook_point = 1500
	var axis_value1 = Input.get_joy_axis(0, JOY_AXIS_0)
	var axis_value2 = Input.get_joy_axis(0, JOY_AXIS_1)
	var _dir = Vector2(stepify(axis_value1,.1), stepify(axis_value2,.1)).normalized()
	var _point = _ray_hook.get_collision_point()
	var _ref = (_point - global_position).normalized() * translate_vel_to_hook_point * delta
	if _special_input:
		hooked = true
		_ray_hook.rotation = _dir.angle()
		if !_ray_hook.is_colliding():
			_ray_hook.cast_to.x += 5
			_point = _ray_hook.get_collision_point()
		if _ray_hook.is_colliding():

			if _ray_hook.get_collider().is_class("StaticBody2D") :
				print("haueh")
			_point = _ray_hook.get_collision_point()
	if _release_special_input:
		$RayHook/Line2D.clear_points()
		move_and_collide(_ref)

		yield(get_tree().create_timer(1), "timeout")
		hooked = false
		_ray_hook.cast_to.x = 0
	$RayHook/Line2D.add_point(_ray_hook.cast_to)

