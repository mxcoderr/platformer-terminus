extends Node

@onready var bgm: AudioStreamPlayer = $BackgroundMusic
@onready var attack: AudioStreamPlayer = $AttackSound
@onready var elixir: AudioStreamPlayer = $ElixirSound
@onready var coin: AudioStreamPlayer = $CoinSound
@onready var jump: AudioStreamPlayer = $JumpSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.DEBUG:
		print("SoundManager is active.")


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
