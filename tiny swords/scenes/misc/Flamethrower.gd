extends Area2D

signal request_restart  # ← novo signal!

@export var damage: int = 5

var can_damage: bool = true
var damage_cooldown := 1.0
var damage_timer := 0.0

func _process(delta):
	if can_damage:
		fire_damage()
	else:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			can_damage = true
			damage_timer = 0.0

func fire_damage():
	can_damage = false
	print("entrou")

	for body in get_overlapping_bodies():
		print("atacou")
		if body.is_in_group("enemies"):
			body.damage(damage)

func restart_timer() -> void:
	print("restart solicitado!")  # Debug opcional
	emit_signal("request_restart")  # ← Level será notificado
