extends Node2D

@export var gravity_coefficient = 7.5

@export var tile_size: int = 128
@export var min_horizontal: int = 2
@export var max_horizontal: int = 6
@export var min_vertical: int = 2
@export var max_vertical: int = 3
@export var count: int = 10 # Amount of platforms preloaded

@export var platforms: Array[PackedScene]
@export var spawn: Node2D # Start platform

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = $Player
	player.apply_config(self)
