extends Area2D

@export var speed: float = 400
@export var lifetime: float = 0.7

@export_category("Extra Efeitos")
@export var pierce_targets: bool = false
@export var hit_vfx: PackedScene
@export var hit_sfx: AudioStream

@onready var damage_area: Area2D = $Area
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var fire1_sprite: Sprite2D
@onready var fire2_sprite: AnimatedSprite2D

var direction: Vector2 = Vector2.RIGHT
var is_upgraded: bool = false


func _ready():
	# Tenta encontrar os sprites (com nomes alternativos)
	_find_sprites()
	
	# Fallback: verifica automaticamente pelo dano
	if GameManager.base_damage > 2:
		is_upgraded = true
		print("Fallback: Detectado upgrade pelo dano (", GameManager.base_damage, ")")
	
	# Configura os sprites baseado no estado
	_setup_sprites()
	_start_lifetime()


func _process(delta):
	position += direction * speed * delta


# ============================================================
#   Procura os sprites com nomes alternativos
# ============================================================
func _find_sprites():
	# Tenta encontrar Fire_1 com nomes diferentes
	fire1_sprite = get_node_or_null("Fire_1")
	if not fire1_sprite:
		fire1_sprite = get_node_or_null("Fire_1_1")
	if not fire1_sprite:
		fire1_sprite = get_node_or_null("Fire_normal")
	
	# Tenta encontrar Fire_2_1 com nomes diferentes
	fire2_sprite = get_node_or_null("Fire_2_1")
	if not fire2_sprite:
		fire2_sprite = get_node_or_null("Fire_2")
	if not fire2_sprite:
		fire2_sprite = get_node_or_null("Fire_blue")
	if not fire2_sprite:
		fire2_sprite = get_node_or_null("Fire_upgraded")
	
	print("=== NÓS ENCONTRADOS ===")
	print("Fire_1 encontrado?", fire1_sprite != null, " - Tipo:", typeof(fire1_sprite) if fire1_sprite else "N/A")
	print("Fire_2_1 encontrado?", fire2_sprite != null, " - Tipo:", typeof(fire2_sprite) if fire2_sprite else "N/A")


# ============================================================
#   Método público para setar o estado do upgrade
# ============================================================
func set_is_upgraded(upgraded: bool):
	is_upgraded = upgraded
	_setup_sprites()
	print("Ataque: Upgrade status = ", is_upgraded)


# ============================================================
#   Configura os sprites (um visível, outro invisível)
# ============================================================
func _setup_sprites():
	print("=== CONFIGURANDO SPRITES ===")
	print("is_upgraded:", is_upgraded)
	
	if is_upgraded:
		# Modo UPGRADED - Fogo azul
		if fire1_sprite:
			fire1_sprite.visible = false
			print("Fire_1 escondido")
		
		if fire2_sprite:
			fire2_sprite.visible = true
			fire2_sprite.play("default")
			print("Fire_2_1 mostrado e animado")
		else:
			print("ERRO: Fire_2_1 não encontrado para modo UPGRADED!")
		
		# Animação
		if animationPlayer:
			if animationPlayer.has_animation("Basic_attack_blue"):
				animationPlayer.play("Basic_attack_blue")
			else:
				animationPlayer.play("Basic_attack")
	else:
		# Modo NORMAL - Fogo normal
		if fire1_sprite:
			fire1_sprite.visible = true
			print("Fire_1 mostrado")
		else:
			print("ERRO: Fire_1 não encontrado para modo NORMAL!")
		
		if fire2_sprite:
			fire2_sprite.visible = false
			fire2_sprite.stop()
			print("Fire_2_1 escondido e parado")
		
		# Animação
		if animationPlayer:
			animationPlayer.play("Basic_attack")


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
