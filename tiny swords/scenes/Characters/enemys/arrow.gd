extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10  # Quantidade de dano que a flecha causa
@onready var shootSfx = $shoot_sfx as AudioStreamPlayer

var direction: Vector2 = Vector2.RIGHT
var has_hit: bool = false
var lifetime: float = 3.0
var time_alive: float = 0.0

func _ready():
	shootSfx.play()
	
	# Rotação da flecha
	rotation = direction.angle()
	
	# Timer de auto-destruição
	if has_node("LifetimeTimer"):
		$LifetimeTimer.wait_time = lifetime
		$LifetimeTimer.start()
	
	# Conectar sinais
	connect_signals()
	
func connect_signals():
	# Conectar sinais de colisão
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	
	# Conectar timer se existir
	if has_node("LifetimeTimer"):
		if not $LifetimeTimer.timeout.is_connected(_on_lifetime_timer_timeout):
			$LifetimeTimer.timeout.connect(_on_lifetime_timer_timeout)

func _physics_process(delta):
	if has_hit:
		return
	
	# Movimento
	position += direction * speed * delta
	
	# Fallback: auto-destruição por tempo
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body):
	handle_collision(body)

func _on_area_entered(area):
	handle_collision(area)

func handle_collision(collider):
	if has_hit:
		return
	# VERIFICA SE É O PLAYER E CAUSA DANO
	if collider.is_in_group("player"):
		
		# Método 1: Se o player tem função damage()
		if collider.has_method("damage"):
			collider.damage(damage)
		
		# Método 2: Se o player tem propriedade health
		elif collider.has_method("take_damage"):
			collider.take_damage(damage)
		
		# Método 3: Acesso direto à propriedade
		elif "health" in collider:
			collider.health -= damage
	
	# Destrói a flecha independente do que atingiu
	has_hit = true
	queue_free()

func _on_lifetime_timer_timeout():
	if not has_hit:
		queue_free()
