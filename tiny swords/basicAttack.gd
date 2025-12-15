extends Area2D

@export var speed: float = 400
@export var lifetime: float = 0.7

@export_category("Extra Efeitos")
@export var pierce_targets: bool = false
@export var hit_vfx: PackedScene
@export var hit_sfx: AudioStream

@onready var damage_area: Area2D = $Area
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var fire1_sprite: Sprite2D = $Fire_1
@onready var fire2_sprite: Sprite2D = $Fire_2

var direction: Vector2 = Vector2.RIGHT
var is_upgraded: bool = false


func _ready():
	# Configura os sprites baseado no estado
	_setup_sprites()
	_start_lifetime()


func _process(delta):
	position += direction * speed * delta


# ============================================================
#   Método público para setar o estado do upgrade
# ============================================================
func set_is_upgraded(upgraded: bool):
	is_upgraded = upgraded
	_setup_sprites()
	print("Ataque: Upgrade status = ", is_upgraded)  # DEBUG


# ============================================================
#   Configura os sprites (um visível, outro invisível)
# ============================================================
func _setup_sprites():
	if fire1_sprite and fire2_sprite:
		if is_upgraded:
			animationPlayer.play("Basic_attack_blue")
			print("Ataque: Mostrando Fire_2 (UPGRADED)")
		else:
			animationPlayer.play("Basic_attack")
			print("Ataque: Mostrando Fire_1 (NORMAL)")


# ============================================================
#   Tempo de vida
# ============================================================
func _start_lifetime():
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()


# ============================================================
#   Quando o ataque colide
# ============================================================
func _on_body_entered(body):
	if body.is_in_group("enemies") or body.is_in_group("sheeps"):
		_apply_damage(body)

# ============================================================
#   DANO
# ============================================================
func _apply_damage(target):
	if target.has_method("damage"):
		target.damage(GameManager.base_damage)
