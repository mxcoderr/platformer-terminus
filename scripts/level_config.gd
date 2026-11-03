extends Node2D
class_name LevelConfig

@export var gravity_coefficient = 7.5

@export var tile_size: int = 128
@export var min_horizontal: int = 2
@export var max_horizontal: int = 4
@export var min_vertical: int = 3
@export var max_vertical: int = 3

@export var platforms: Array[PackedScene]
@export var spawn: Node2D # Start platform

enum ElixirType {JUMP, MOVE, GRAVITY}

var coin_chance = 0.3
var zombie_chance = 0.05
#var jump_elixir_chance = 0.1
#var movement_elixir_chance = 0.1
#var gravity_elixir_chance = 0.1
var elixir_chance = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = $Player
	player.apply_config(self)
