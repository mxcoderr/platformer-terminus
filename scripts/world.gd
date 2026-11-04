extends Node2D

@onready var level_config: Node = get_node("..")
var rng := RandomNumberGenerator.new()
var last_pos: Vector2
var player: CharacterBody2D
const COIN = preload("res://scenes/coin.tscn")
const ZOMBIE_MALE = preload("res://scenes/zombie_male.tscn")
const ZOMBIE_FEMALE = preload("res://scenes/zombie_female.tscn")
var ELIXIR = preload("res://scenes/elixir.tscn")

var active_elixirs: Array[bool]
var placed_elixirs: Array[int]	# "Elixir i active since placed_elixirs[i] platforms"

var gravity = true
var current_plat_length: int

func _ready() -> void:
	rng.seed = GameManager.current_seed
	if GameManager.DEBUG:
		print("Seed: " + str(rng.seed))
	
	active_elixirs.resize(level_config.ElixirType.values().size())
	active_elixirs.fill(false)
	
	placed_elixirs.resize(level_config.ElixirType.values().size())
	placed_elixirs.fill(-1)
	
	player = level_config.get_node("Player")
	
	generate_platform(Vector2(0,0))

func _process(_delta):
	# When player gets in range call generate_platform, to generate a new platform
	if player.position.x > last_pos.x - 2048:
		generate_platform()

	# Remove platform when player gets further away to reduce lag on long games
	for child in get_children():
		if child is Node2D and child != level_config.spawn:
			if child.position.x < player.position.x - 4096:
				child.queue_free()

# Generates one platform
# pos: Vector2 - explicit position of the next platform
func generate_platform(pos: Variant = null):
	for i in placed_elixirs.size():
		if not (placed_elixirs[i] == -1):
			placed_elixirs[i] += 1
	
	var scene: PackedScene = level_config.platforms[rng.randi_range(0, level_config.platforms.size() - 1)]
	var plat: Node2D = scene.instantiate()
	
	if pos is Vector2:
		plat.position = pos
	else:
		# The range sets the probability for platforms on same y level. 
		# The higher the range the lower the probability for the next platform to be on the same y level.
		var direction: int = rng.randi_range(-3, 3)
		var direction_y: float = 0
		if direction < 0:
			direction_y = -(rng.randf_range(level_config.min_vertical, level_config.max_vertical) * level_config.tile_size)
		elif direction > 0:
			direction_y = rng.randf_range(level_config.min_vertical, level_config.max_vertical) * level_config.tile_size

		var max_x: float = max(level_config.min_horizontal, level_config.max_horizontal - abs(direction_y) / level_config.tile_size)
		var direction_x: float = rng.randf_range(level_config.min_horizontal, max_x) * level_config.tile_size
		
		plat.position = last_pos + Vector2(direction_x, direction_y)

	var plat_tile_map_layer = plat.get_node("TileMapLayer")
	var plat_rect = plat_tile_map_layer.get_used_rect()
	var tile_size = Vector2(plat_tile_map_layer.tile_set.tile_size)
	var top_left = Vector2(plat_rect.position) * tile_size
	current_plat_length = plat_rect.size.x * tile_size.x
	var top_right = top_left + Vector2(current_plat_length, 0)
	
	if gravity:
		last_pos = plat.position + top_right
	else:
		plat.rotate(PI)
		plat.position += Vector2(current_plat_length, 0)
		last_pos = plat.position
	
	if pos is not Vector2: generate_placeables(plat)
	
	add_child(plat)

# Places coins, enemies and elixirs on the platform randomly
func generate_placeables(plat):
	# Check if an elixir must be placed because of max duration expiry
	for elixir_type in placed_elixirs.size():
		if placed_elixirs[elixir_type] >= level_config.max_elixir_duration:
			var elixir = ELIXIR.instantiate()
			elixir.initialize(elixir_type)
			elixir.collected.connect(player._on_elixir_activated)
			elixir.position = Vector2(current_plat_length / 2.0, -60.0)
			
			plat.add_child(elixir)
			
			# Effect ends due to duration expiry
			placed_elixirs[elixir_type] = 0
			
			apply_elixir_effect(elixir_type)
		break
	
	var die = rng.randi() % 100
	var coin_threshold = level_config.coin_chance * 100
	var zombie_threshold = coin_threshold + level_config.zombie_chance * 100
	var elixir_threshold = zombie_threshold + level_config.elixir_chance * 100
	
	if die < coin_threshold:
		var coin = COIN.instantiate()
		coin.position = Vector2(current_plat_length / 2.0, -60.0)
		plat.add_child(coin)
	elif die < zombie_threshold:
		var zombie
		if(rng.randi() % 2 == 0):
			zombie = ZOMBIE_MALE.instantiate()
		else:
			zombie = ZOMBIE_FEMALE.instantiate()
		zombie.gravity_coefficient = bool_to_sign(gravity)
		zombie.position = Vector2(current_plat_length / 2.0, -60.0)
		zombie.apply_config(player)
		plat.add_child(zombie)
	elif die < elixir_threshold:
		var elixir_types = level_config.ElixirType.values()
		var elixir_type = rng.randi() % elixir_types.size()
		
		# Place the randomly chosen elixir for the first time or if its min duration expired
		if placed_elixirs[elixir_type] == -1 or placed_elixirs[elixir_type] > level_config.min_elixir_duration:
			var elixir = ELIXIR.instantiate()
			elixir.initialize(elixir_type)
			elixir.collected.connect(player._on_elixir_activated)
			elixir.position = Vector2(current_plat_length / 2.0, -60.0)
			
			plat.add_child(elixir)
			
			placed_elixirs[elixir_type] = 0
		
			apply_elixir_effect(elixir_type)

func apply_elixir_effect(elixir_type: int):
	active_elixirs[elixir_type] = not active_elixirs[elixir_type]
	
	if elixir_type == 0:
		if active_elixirs[elixir_type]:
			level_config.min_vertical *= level_config.jump_elixir_factor
			level_config.max_vertical *= level_config.jump_elixir_factor
		else:
			level_config.min_vertical /= level_config.jump_elixir_factor
			level_config.max_vertical /= level_config.jump_elixir_factor
	elif elixir_type == 1:
		if active_elixirs[elixir_type]:
			level_config.min_horizontal *= level_config.movement_elixir_factor
			level_config.max_horizontal *= level_config.movement_elixir_factor
		else:
			level_config.min_horizontal /= level_config.movement_elixir_factor
			level_config.max_horizontal /= level_config.movement_elixir_factor
	elif elixir_type == 2:
		gravity = not gravity
		generate_platform(last_pos + Vector2(0, bool_to_sign(gravity) * 1000))

func bool_to_sign(boolean: bool) -> int:
	return 1 if boolean else -1
