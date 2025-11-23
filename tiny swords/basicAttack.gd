extends Area2D

@export var speed: float = 400
@export var lifetime: float = 0.7
@export var damage_amount: int = 2

@export_category("Extra Efeitos")
@export var pierce_targets: bool = false  # TRUE = atravessa vários inimigos
@export var hit_vfx: PackedScene
@export var hit_sfx: AudioStream

@onready var damage_area: Area2D = $Area
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

var direction: Vector2 = Vector2.RIGHT


func _ready():
	_start_lifetime()
	animationPlayer.play("Basic_attack")


func _process(delta):
	position += direction * speed * delta


# ============================================================
#   Tempo de vida sem Timer
# ============================================================
func _start_lifetime():
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()


# ============================================================
#   Quando o ataque colide com um inimigo
# ============================================================
func _on_body_entered(body):
		if body.is_in_group("enemies") or body.is_in_group("sheeps"):
			_apply_damage(body)

# ============================================================
#   DANO
# ============================================================
func _apply_damage(target):
	if target.has_method("damage"):
		target.damage(damage_amount)
