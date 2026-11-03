extends Node2D
class_name GameWorld

@onready var config: Node = get_node("..")
var rng := RandomNumberGenerator.new()
var last_pos: Vector2
var player: Node2D
const COIN = preload("res://scenes/coin.tscn")
const ZOMBIE_MALE = preload("res://scenes/zombie_male.tscn")
const ZOMBIE_FEMALE = preload("res://scenes/zombie_female.tscn")
var ELIXIR = preload("res://scenes/elixir.tscn")

var active_elixirs: Array[bool]
var placed_elixirs: Array[bool]

var jump_elixir_factor = 1.5
var movement_elixir_factor = 1.5

var gravity = true

func _ready() -> void:
	rng.set_seed(0)
	active_elixirs.resize(config.ElixirType.values().size())
	active_elixirs.fill(false)
	
	placed_elixirs.resize(config.ElixirType.values().size())
	placed_elixirs.fill(false)
	
	player = config.get_node("Player")
	#527, -141
	var layer = config.spawn.tile_map
	var rect = layer.get_used_rect()
	var tileSize = Vector2(layer.tile_set.tile_size)
	var top_left_local = Vector2(rect.position) * tileSize
	var top_right_local = top_left_local + Vector2(rect.size.x * tileSize.x, 0)

	var top_right_global = layer.to_global(top_right_local)
	
	"""print("rect.size :", rect.size)
	print("tileSize :", tileSize)
	print("platform length = {rect.size.x} * {tileSize.x} = ", rect.size.x * tileSize.x)
	
	print("rect.position : ", rect.position)
	print("top_left_local : ", top_left_local)
	
	print("top_right_local : ", top_right_local)
	print("top_right_global", top_right_global)"""
	
	last_pos = top_right_global
	#last_pos = Vector2(2304,1152)
	#last_pos = config.spawn.exit_pos
	
	generate_one()

func _on_elixir_activated(elixir_type: int) -> void:
	active_elixirs[elixir_type] = not active_elixirs[elixir_type]
	
	#print("Collected elixir of type ", elixir_type)
	#print("active_elixirs : ", active_elixirs)
	
	if elixir_type == 0:
		if active_elixirs[elixir_type]:
			$"../Player".JUMP_VELOCITY *= jump_elixir_factor
		else:
			$"../Player".JUMP_VELOCITY /= jump_elixir_factor
	elif elixir_type == 1:
		if active_elixirs[elixir_type]:
			$"../Player".SPEED *= movement_elixir_factor
		else:
			$"../Player".SPEED /= movement_elixir_factor
	elif elixir_type == 2:
		$"../Player".up_direction.y *= -1
	
	#print("SPEED : ", $"../Player".SPEED)
	#print("JUMP_VELOCITY : ", $"../Player".JUMP_VELOCITY)
	#print("min_horizontal : ", config.min_horizontal)
	#print("max_horizontal : ", config.max_horizontal)

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
			direction_y = -(rng.randi_range(config.min_vertical, config.max_vertical) * config.tile_size)
		elif direction > 0:
			direction_y = rng.randi_range(config.min_vertical, config.max_vertical) * config.tile_size

		var max_x: int = max(config.min_horizontal, config.max_horizontal - abs(direction_y) / config.tile_size)
		var direction_x: int = rng.randi_range(config.min_horizontal, max_x) * config.tile_size
	
		var scene: PackedScene = config.platforms[rng.randi_range(0, config.platforms.size() - 1)]
		var plat: Node2D = scene.instantiate()
		
		plat.position = last_pos + Vector2(direction_x, direction_y)
		
		if not gravity:
			plat.rotate(PI)

		var plat_tile_map_layer = plat.get_node("TileMapLayer")
		var plat_rect = plat_tile_map_layer.get_used_rect()
		var tile_size = Vector2(plat_tile_map_layer.tile_set.tile_size)
		
		var top_left = Vector2(plat_rect.position) * tile_size
		
		var plat_length = plat_rect.size.x * tile_size.x
		
		var top_right = top_left + Vector2(plat_length, 0)
		
		if not gravity:
			plat.position += Vector2(plat_length, 0)

		last_pos = plat.position + top_right if gravity else plat.position
		
		generate_placeables(plat)
		
		add_child(plat)

# Places coins, enemies and elixirs on the platform randomly
func generate_placeables(plat):
	var die = rng.randi() % 100
	var coin_threshold = $"..".coin_chance * 100
	var zombie_threshold = coin_threshold + $"..".zombie_chance * 100
	var elixir_threshold = zombie_threshold + $"..".elixir_chance * 100
	
	#print("die = ", die)
	#print("coin_threshold = ", coin_threshold)
	#print("zombie_threshold = ", zombie_threshold)
	#print("elixir_threshold = ", elixir_threshold)
	
	if die < coin_threshold:
		var coin = COIN.instantiate()
		coin.position = Vector2(200, -60)
		plat.add_child(coin)

		#print("coin placed")
	elif die < zombie_threshold:
		var zombie
		if(rng.randi() % 2 == 0):
			zombie = ZOMBIE_MALE.instantiate()
			#print("zombie male placed")
		else:
			zombie = ZOMBIE_FEMALE.instantiate()
			#print("zombie female placed")
		if not gravity:
			zombie.gravity_coefficient *= -1
			#zombie.direction *= -1
			#zombie.floor_checker.position.y *= -1
		zombie.position = Vector2(200, -60)
		zombie.apply_config(player)
		plat.add_child(zombie)
	elif die < elixir_threshold:
		var elixir = ELIXIR.instantiate()
		var elixir_types = config.ElixirType.values()
		var elixir_type = rng.randi() % elixir_types.size()
		
		elixir.initialize(elixir_type)
		
		elixir.collected.connect(_on_elixir_activated)
		
		elixir.position = Vector2(300, -60)
		plat.add_child(elixir)
		
		placed_elixirs[elixir_type] = not placed_elixirs[elixir_type]
		
		#print("Placing elixir of type ", elixir_type)
		if elixir_type == 0:
			if placed_elixirs[elixir_type]:
				$"..".min_vertical *= 2
				$"..".max_vertical *= 2
			else:
				$"..".min_vertical /= 2
				$"..".max_vertical /= 2
		elif elixir_type == 1:
			if placed_elixirs[elixir_type]:
				#print("Increasing the gap between platforms...")
				$"..".min_horizontal *= movement_elixir_factor
				$"..".max_horizontal *= movement_elixir_factor
			else:
				#print("Decreasing the gap between platforms...")
				$"..".min_horizontal /= movement_elixir_factor
				$"..".max_horizontal /= movement_elixir_factor
		elif elixir_type == 2:
			gravity = not gravity
			#if placed_elixirs[elixir_type]:
			var scene: PackedScene = config.platforms[rng.randi_range(0, config.platforms.size() - 1)]
			var opposite_plat: Node2D = scene.instantiate()
			opposite_plat.position = last_pos + Vector2(0, bool_to_sign(gravity) * 1000)
			#print("last_pos : ", last_pos)
			#print("opposite_plat.position : ", opposite_plat.position)
			
			if not gravity:
				opposite_plat.rotate(PI)
			
			var plat_tile_map_layer = opposite_plat.get_node("TileMapLayer")
			var plat_rect = plat_tile_map_layer.get_used_rect()
			var tile_size = Vector2(plat_tile_map_layer.tile_set.tile_size)
			
			var top_left = Vector2(plat_rect.position) * tile_size
			
			var plat_length = plat_rect.size.x * tile_size.x
			
			var top_right = top_left + Vector2(plat_length, 0)
			
			if not gravity:
				opposite_plat.position += Vector2(plat_length, 0)

			last_pos = opposite_plat.position + top_right if gravity else opposite_plat.position
			
			add_child(opposite_plat)
			last_pos = opposite_plat.position

func bool_to_sign(boolean: bool) -> int:
	return 1 if boolean else -1
