extends Node2D

@onready var config: Node = get_node("..")
var rng := RandomNumberGenerator.new()
var last_pos: Vector2
var player: Node2D
const COIN = preload("res://scenes/coin.tscn")

func _ready() -> void:
	rng.set_seed(0)
	rng.randi()
	player = get_node("%Player")
	last_pos = config.spawn.exit_pos
	generate_one()

func _process(_delta):
#	When player gets in range call generate_one, to generate a new platform
	if player.position.x > last_pos.x - 2048:
		generate_one()

#	Remove platform when player gets further away to reduce lag on long games
	for child in get_children():
		if child is Node2D and child != config.spawn:
			if child.position.x < player.position.x - 4096:
				child.queue_free()

# Generate one platform
func generate_one():
#		The range sets the probability for platforms on same y level. 
#		The higher the range the lower the probability for the next platform to be on the same y level.
		var direction: int = rng.randi_range(-3, 3)
		var direction_y: int = 0
		if direction < 0:
			direction_y = -rng.randi_range(config.min_vertical, config.max_vertical) * config.tile_size
		elif direction > 0:
			direction_y = rng.randi_range(config.min_vertical, config.max_vertical) * config.tile_size

		var max_x: int = max(config.min_horizontal, config.max_horizontal - abs(direction_y) / config.tile_size)
		var direction_x: int = rng.randi_range(config.min_horizontal, max_x) * config.tile_size
	
		var scene: PackedScene = config.platforms[rng.randi_range(0, config.platforms.size() - 1)]
		var plat: Node2D = scene.instantiate()
		plat.position = last_pos + Vector2(direction_x, direction_y)
		add_child(plat)
		
		if rng.randi() % 5 == 0:
			var coin = COIN.instantiate()
			coin.position = Vector2(200, -60)
			plat.add_child(coin)
		
		last_pos = plat.position
