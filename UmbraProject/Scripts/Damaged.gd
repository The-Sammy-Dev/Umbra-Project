extends Area2D

signal player_attack
func _ready():
	connect("area_entered", self, "_on_area_entered")
	add_to_group("zombie")

func _on_area_entered(area):
	pass
