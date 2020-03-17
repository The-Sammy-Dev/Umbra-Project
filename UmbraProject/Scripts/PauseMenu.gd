extends Control

signal in_options

onready var sound_menu_anim: AudioStreamPlayer = $sound_menu_anim
onready var anim = $Anim
onready var resume_button: Button = $ResumeButton
onready var options_button: Button = $OptionsButton
onready var exit_button: Button = $ExitButton

var in_options_button = false
onready var sound_bar: HSlider = $InOptions/SoundBar
onready var full_screen_button: CheckBox = $InOptions/FullScreen
onready var effects_bar: HSlider = $InOptions/SoundsEffects
var can_esc = true

func _ready() -> void:
	resume_button.connect("button_down", self, "_on_resumebutton_down")
	resume_button.connect("button_up", self, "_on_resumebutton_up" )
	
	full_screen_button.visible = false
	sound_bar.visible = false
	effects_bar.visible = false
	
	Event.connect("game_paused", self, "_on_Event_game_pause")
	
	resume_button.connect("pressed", self, "_on_resume_button_pressed")
	options_button.connect("pressed", self, "_on_options_button_pressed")
	exit_button.connect("pressed", self, "_on_exit_button_pressed")
	
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("input_pause") and can_esc :
		_pause_and_resume()
	
func _pause_and_resume():
#	if anim.current_animation and in_options_button: return
#	if anim.current_animation_position > 0 and in_options_button: return
	if get_tree().paused :
		if in_options_button :
			full_screen_button.visible = false
			sound_bar.visible = false
			effects_bar.visible = false
			_button_visible(true)
			anim.play("pause")
			sound_menu_anim.play()
			yield(anim, "animation_finished")
			_button_disconect(false)
			in_options_button = false
		else:
			_button_disconect(true)
			anim.play_backwards("pause", 1)
			yield(anim, "animation_finished")
			visible = false
			get_tree().paused = false
	else:
		get_tree().paused = true
		sound_menu_anim.play()
		_button_disconect(true)
		visible = true
		_button_visible(true)
		anim.play("pause")
		yield(anim, "animation_finished")
		_button_disconect(false)
		
#	get_tree().paused = !get_tree().paused
	
func _on_options_button_pressed():
	_button_disconect(true)
	in_options_button = true
	can_esc = false
	
	anim.play_backwards("pause", 1)
	
	yield(anim, "animation_finished")
	
	_button_visible(false)
	sound_bar.visible = true
	effects_bar.visible = true
	can_esc = true
	full_screen_button.visible = true

func _on_exit_button_pressed():
	pass
	
func _on_Event_game_pause():
	visible = true
	anim.play("pause")
	get_tree().paused = true

func _on_resume_button_pressed():
	_resume_game()

func _button_visible(_visible: bool):
	resume_button.visible = _visible
	options_button.visible = _visible
	exit_button.visible = _visible

func _button_disconect(_disconect : bool):
	
	resume_button.set_block_signals(_disconect)
	options_button.set_block_signals(_disconect)
	exit_button.set_block_signals(_disconect)

		
func _resume_game():
	anim.play_backwards("pause", 1)
	
	yield(anim, "animation_finished")
	
	visible = false
	get_tree().paused = false
	Event.emit_signal("resume_game")
	
