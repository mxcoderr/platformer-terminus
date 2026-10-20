extends Node2D

@export var gravity_coefficient = 7.5

@export var tile_size: int = 128
@export var min_horizontal: int = 4
@export var max_horizontal: int = 6
@export var min_vertical: int = 3
@export var max_vertical: int = 3

@export var platforms: Array[PackedScene]
@export var spawn: Node2D # Start platform

var coin_chance = 0.4
var zombie_chance = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = $Player
	player.apply_config(self)
