extends Area2D


#@export var orbit_radius := 200
#@export var orbit_speed := 3.0
#
#var angle := 0.0


func _process(delta):
	pass

func _on_body_entered(body):
	print("tested")
	if body.is_in_group("enemies") or body.is_in_group("sheeps"):
		_apply_damage(body)


# ============================================================
#   DANO
# ============================================================
func _apply_damage(target):
	if target.has_method("damage"):
		target.damage(GameManager.base_damage)
