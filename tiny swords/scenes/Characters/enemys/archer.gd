extends "res://scenes/Characters/enemys/enemy.gd" 

class_name Archer

@export var arrow_prefab: PackedScene  # ← Carregar a cena da flecha depois
@export var attack_range: float = 300.0
@export var flee_range: float = 100.0  # Opcional: distancia mínima para fugir

@onready var arrow_spawn: Marker2D = $ArrowSpawn  # ← REFERÊNCIA AO MARKER

func _ready():
	super._ready()
