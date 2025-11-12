extends Area2D

@export var damage: int = 5
@onready var attack_cooldown:float = 0
@onready var can_damage:bool = true
@onready var damage_cooldown = 1.0  # Cooldown period in seconds
@onready var damage_timer = 0.0

func _process(delta):
	if can_damage:
		fire_damage(delta)
	else:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			can_damage = true
			damage_timer = 0.0

func fire_damage(delta):
	can_damage = false
	print("entrou")
	var bodies = self.get_overlapping_bodies()
	for body in bodies:
		print("atacou")
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			enemy.damage(damage)
	
func restart_timer()->void:
	var player = self.get_parent()
	var world = player.get_parent()
	var gameui:GameUI = world.get_node("gameui")
	if gameui.has_method("restart"):
		gameui.restart()
