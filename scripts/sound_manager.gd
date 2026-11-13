extends Node

const MUSIC_BUS := "Music"
const ATTACK_BUS := "Attack"
const ELIXIR_BUS := "Elixir"
const COIN_BUS := "Coin"
const JUMP_BUS := "Jump"

const SAVE_PATH := "user://settings.json"
 
@onready var bgm: AudioStreamPlayer = $BackgroundMusic
@onready var attack: AudioStreamPlayer = $AttackSound
@onready var elixir: AudioStreamPlayer = $ElixirSound
@onready var coin: AudioStreamPlayer = $CoinSound
@onready var jump: AudioStreamPlayer = $JumpSound

const BGM_SFX = preload("res://assets/sounds/background_music.mp3")
const ATTACK_SFX = preload("res://assets/sounds/attack_hit.mp3")
const ELIXIR_SFX = preload("res://assets/sounds/potion_pickup.mp3")
const COIN_SFX = preload("res://assets/sounds/coin_pickup.mp3")
const JUMP_SFX = preload("res://assets/sounds/jump.mp3")
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.DEBUG:
		print("SoundManager is active.")
	
	load_settings()
		
	bgm.stream = BGM_SFX
	coin.stream   = COIN_SFX
	jump.stream   = JUMP_SFX
	attack.stream = ATTACK_SFX
	elixir.stream = ELIXIR_SFX
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if bgm.playing == false:
		bgm.play()

func play_attack() -> void:
	attack.play()

func play_elixir() -> void:
	elixir.play()

func play_coin() -> void:
	coin.play()

func play_jump() -> void:
	jump.play()

func set_music_volume(percent: float) -> void:
	var db: float = linear_to_db(percent)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), db)

func set_attack_volume(percent: float) -> void:
	var db: float = linear_to_db(percent)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(ATTACK_BUS), db)
	
func set_elixir_volume(percent: float) -> void:
	var db: float = linear_to_db(percent)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(ELIXIR_BUS), db)

func set_coin_volume(percent: float) -> void:
	var db: float = linear_to_db(percent)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(COIN_BUS), db)
	
func set_jump_volume(percent: float) -> void:
	var db: float = linear_to_db(percent)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(JUMP_BUS), db)

func get_music_volume() -> float:
	var db: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS))
	return db_to_linear(db)

func get_attack_volume() -> float:
	var db: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(ATTACK_BUS))
	return db_to_linear(db)
	
func get_elixir_volume() -> float:
	var db: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(ELIXIR_BUS))
	return db_to_linear(db)

func get_coin_volume() -> float:
	var db: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(COIN_BUS))
	return db_to_linear(db)
	
func get_jump_volume() -> float:
	var db: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(JUMP_BUS))
	return db_to_linear(db)
	
func save_settings() -> void:
	var data := {
		"music": get_music_volume(),
		"attack": get_attack_volume(),
		"elixir": get_elixir_volume(),
		"coin": get_coin_volume(),
		"jump": get_jump_volume(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		
func load_settings() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			set_music_volume(parsed["music"])
			set_attack_volume(parsed["attack"])
			set_elixir_volume(parsed["elixir"])
			set_coin_volume(parsed["coin"])
			set_jump_volume(parsed["jump"])
