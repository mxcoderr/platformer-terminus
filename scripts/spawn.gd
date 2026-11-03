extends Node2D

#@export var exit_pos: Vector2 = Vector2(2304,1152) # (18,9)
var tile_map: TileMapLayer

func _ready() -> void:
	tile_map = $"TileMap"
