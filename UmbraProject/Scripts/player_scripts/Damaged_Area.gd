extends Area2D

signal pick_coin
signal impulse

func _ready():
	connect("area_entered", self, "_on_damageplayer_area_entered")
	connect("body_entered", self, "_on_body_entered")

func _on_damageplayer_area_entered(area):
	if area.get_parent().is_in_group("monster"):
		if get_parent().has_method("v_movement"):
			emit_signal("impulse")
		
func _on_body_entered(body):
	if body.is_in_group("zombie") or body.is_in_group("monster") :
		if get_parent().has_method("on_damaged"):
			get_parent().on_damaged(body)
	
	if body.is_in_group("hearth"):
		if get_parent().has_method("_pick_life"):
			get_parent()._pick_life(2)
		if body.has_method("_picked"):
			body._picked()
				
	if body.is_in_group("coin"):
		if body.has_method("pick_coin"):
			body.pick_coin()
			emit_signal("pick_coin")
