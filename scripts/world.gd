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
var movement_elixir_factor = 1.5

func _ready() -> void:
	rng.seed = ScoreManager.current_seed
	print("Seed: " + str(rng.seed))
	
	active_elixirs.resize(config.ElixirType.values().size())
	active_elixirs.fill(false)
	
	placed_elixirs.resize(config.ElixirType.values().size())
	placed_elixirs.fill(false)
	
	print("active_elixirs : ", active_elixirs)
	print("SPEED : ", $"../Player".SPEED)
	
	#print("active_elixirs : ", active_elixirs)
	#rng.randi()
	#rng = config.rng
	player = config.get_node("Player")
	last_pos = config.spawn.exit_pos
	generate_one()

func _on_elixir_activated(elixir_index: int) -> void:
	active_elixirs[elixir_index] = not active_elixirs[elixir_index]
	
	print("Collected elixir of type ", elixir_index)
	print("active_elixirs : ", active_elixirs)
	
	if elixir_index == 2:
		if active_elixirs[2]:
			$"../Player".SPEED *= movement_elixir_factor
		else:
			$"../Player".SPEED /= movement_elixir_factor
	
	print("SPEED : ", $"../Player".SPEED)
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
			direction_y = -rng.randi_range(config.min_vertical, config.max_vertical) * config.tile_size
		elif direction > 0:
			direction_y = rng.randi_range(config.min_vertical, config.max_vertical) * config.tile_size

		var max_x: int = max(config.min_horizontal, config.max_horizontal - abs(direction_y) / config.tile_size)
		var direction_x: int = rng.randi_range(config.min_horizontal, max_x) * config.tile_size
	
		var scene: PackedScene = config.platforms[rng.randi_range(0, config.platforms.size() - 1)]
		var plat: Node2D = scene.instantiate()
		plat.position = last_pos + Vector2(direction_x, direction_y)
		add_child(plat)
		last_pos = plat.position
		
		generate_placeables(plat)

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
		zombie.position = Vector2(200, -60)
		zombie.apply_config(player)
		plat.add_child(zombie)
	elif die < elixir_threshold:
		var elixir = ELIXIR.instantiate()
		var elixir_types = config.ElixirType.values()
		#var elixir_type: LevelConfig.ElixirType = elixir_types[rng.randi() % elixir_types.size()]
		#print(elixir_type)
		var elixir_type = rng.randi() % elixir_types.size()
		elixir.initialize(elixir_type)
		
		elixir.collected.connect(_on_elixir_activated)
		
		elixir.position = Vector2(200, -60)
		plat.add_child(elixir)
		
		placed_elixirs[elixir_type] = not placed_elixirs[elixir_type]
		
		#print("Placing elixir of type ", elixir_type)
		if elixir_type == 2:
			if placed_elixirs[2]:
				#print("Increasing the gap between platforms...")
				$"..".min_horizontal *= movement_elixir_factor
				$"..".max_horizontal *= movement_elixir_factor
			else:
				#print("Decreasing the gap between platforms...")
				$"..".min_horizontal /= movement_elixir_factor
				$"..".max_horizontal /= movement_elixir_factor
		print("min_horizontal : ", $"..".min_horizontal)
		print("max_horizontal : ", $"..".max_horizontal)

	#print("\n----------------\n")
