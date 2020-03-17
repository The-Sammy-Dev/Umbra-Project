extends Sprite

var vel = 2.0
var dir = 1

func _ready():
	
	pass

func _physics_process(delta: float) -> void:
	get_parent().unit_offset += (dir * vel) * delta
