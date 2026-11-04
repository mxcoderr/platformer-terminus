extends Node

var player_died: bool = false
var current_seed: int = 0
@export var DEBUG: bool = true

func _ready() -> void:
	if DEBUG:
		print("GameManager is active.")
