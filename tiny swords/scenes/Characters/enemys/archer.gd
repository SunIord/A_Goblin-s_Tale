extends "res://scenes/Characters/enemys/enemy.gd" 

class_name Archer

@export var arrow_prefab: PackedScene  # ← Carregar a cena da flecha depois
@export var attack_range: float = 300.0
@export var flee_range: float = 100.0  # Opcional: distancia mínima para fugir

@onready var arrow_spawn: Marker2D = $ArrowSpawn  # ← REFERÊNCIA AO MARKER

func _ready():
	super._ready()
	
	# Debug detalhado
	print("=== ARCHER CONFIG ===")
	print("📦 Arrow Prefab: ", "✅" if arrow_prefab else "❌ NÃO CONFIGURADO")
	print("🎯 Arrow Spawn: ", "✅ " + arrow_spawn.name if arrow_spawn else "❌ NÃO ENCONTRADO")
	print("🎯 Attack Range: ", attack_range)
	print("🎯 Health: ", health)
	
	# Verifica estrutura da cena
	print("\n=== ESTRUTURA DO ARCHER ===")
	for child in get_children():
		print("  - ", child.name, " (", child.get_class(), ")")
