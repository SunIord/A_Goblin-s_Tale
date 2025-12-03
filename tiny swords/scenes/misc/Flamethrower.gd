extends Area2D

signal request_restart  # ← novo signal!

@export var damage: int = 5
@onready var spellSfx = $spell_sfx as AudioStreamPlayer

var can_damage: bool = true
var damage_cooldown := 1.0
var damage_timer := 0.0

# ======= MEDIÇÃO DE DURAÇÃO =======
var start_time := 0

func _ready():
	spellSfx.play()
	# Marca o tempo inicial
	start_time = Time.get_ticks_msec()

	# Detecta quando o node for destruído
	tree_exiting.connect(_on_spell_exiting)

# ==================================

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


# ======== CALLBACK DE REMOÇÃO ========
func _on_spell_exiting():
	var end_time = Time.get_ticks_msec()
	var duration_ms = end_time - start_time
	var duration_sec = float(duration_ms) / 1000.0

	print("🔥 Especial durou ", duration_ms, " ms (", duration_sec, " segundos )")
