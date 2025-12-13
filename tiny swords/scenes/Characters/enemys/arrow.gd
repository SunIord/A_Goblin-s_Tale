extends Area2D

class_name Arrow

@export var speed: float = 400.0
@export var damage: int = 5
@export var lifetime: float = 3.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.RIGHT
var has_hit: bool = false
var life_timer: float = 0.0

func _ready():
	# Configura sprite com 1 frame
	if sprite.sprite_frames:
		sprite.play("default")  # Nome da animação de 1 frame
	
	rotation = direction.angle()
	print("✅ Flecha criada em: ", global_position, " Rotação: ", rotation)

func _physics_process(delta):
	if has_hit:
		return
	
	position += direction * speed * delta
	
	# Auto-destruição por tempo
	life_timer += delta
	if life_timer >= lifetime:
		print("⏰ Flecha expirou na posição: ", global_position)
		queue_free()

func _on_body_entered(body):
	if has_hit:
		return
	
	print("🎯 Colisão detectada com: ", body.name if body else "null")
	
	if body and body.is_in_group("player"):
		print("🎯 Flecha acertou player!")
		body.damage(damage)
		has_hit = true
	
	queue_free()
