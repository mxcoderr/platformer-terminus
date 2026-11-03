extends Node2D
class_name LevelConfig

@export var gravity_coefficient = 7.5

@export var tile_size: int = 128
@export var min_horizontal: float = 2
@export var max_horizontal: float = 3
@export var min_vertical: float = 3
@export var max_vertical: float = 3

@export var platforms: Array[PackedScene]
@export var spawn: Node2D # Start platform

enum ElixirType {JUMP, MOVE, GRAVITY}

var jump_elixir_factor = 1.2
var movement_elixir_factor = 1.3

var coin_chance = 0.3
var zombie_chance = 0.05
var elixir_chance = 0.5

var min_elixir_duration = 5		# minimal amount of platforms where elixir should be active
var max_elixir_duration = 10	# maximal amount of platforms where elixir should be active

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = $Player
	player.apply_config(self)
