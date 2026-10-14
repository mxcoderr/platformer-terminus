extends Node2D

@export var gravity_coefficient = 7.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = $Player
	player.apply_config(self)
