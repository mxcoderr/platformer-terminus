extends Control

@onready var menu_buttons: Control = $UI/MainGroup/MenuButtons
@onready var new_game_group: Control = $UI/NewGameGroup
@onready var settings_group: Control = $UI/SettingsGroup
@onready var credits_group: Control = $UI/CreditsGroup

@onready var music_slider: HSlider = $UI/SettingsGroup/VBoxContainer/BackgroundMusicSlider
@onready var attack_slider: HSlider = $UI/SettingsGroup/VBoxContainer/SwordSwingSlider
@onready var elixir_slider: HSlider = $UI/SettingsGroup/VBoxContainer/JumpSlider
@onready var coin_slider: HSlider = $UI/SettingsGroup/VBoxContainer/CoinSlider
@onready var jump_slider: HSlider = $UI/SettingsGroup/VBoxContainer/ElixirSlider

var active_group: Control = null

func _ready():
	_hide_all_groups()
	
	if GameManager.player_died:
		menu_buttons.visible = false
		GameManager.player_died = false

	$UI/MainGroup/MenuButtons/NewGame.pressed.connect(func(): _show_group(new_game_group))
	$UI/MainGroup/MenuButtons/Settings.pressed.connect(func(): _show_group(settings_group))
	$UI/MainGroup/MenuButtons/Credits.pressed.connect(func(): _show_group(credits_group))
	$UI/MainGroup/MenuButtons/QuitGame.pressed.connect(func(): get_tree().quit())

	$UI/NewGameGroup/BackNewGame.pressed.connect(show_menu)
	$UI/NewGameGroup/StartNewGame.pressed.connect(_on_start)
	
	$UI/CreditsGroup/BackCredits.pressed.connect(show_menu)
	
	$UI/SettingsGroup/BackSettings.pressed.connect(_on_settings_back)

	music_slider.value = SoundManager.get_music_volume() * 100.0
	attack_slider.value = SoundManager.get_attack_volume() * 100.0
	elixir_slider.value = SoundManager.get_elixir_volume() * 100.0
	coin_slider.value = SoundManager.get_coin_volume() * 100.0
	jump_slider.value = SoundManager.get_jump_volume() * 100.0
	
	music_slider.value_changed.connect(_on_music_changed)
	attack_slider.value_changed.connect(_on_attack_changed)
	elixir_slider.value_changed.connect(_on_elixir_changed)
	coin_slider.value_changed.connect(_on_coin_changed)
	jump_slider.value_changed.connect(_on_jump_changed)

func _on_music_changed(value: float):
	SoundManager.set_music_volume(value / 100.0)

func _on_attack_changed(value: float):
	SoundManager.set_attack_volume(value / 100.0)

func _on_elixir_changed(value: float):
	SoundManager.set_elixir_volume(value / 100.0)

func _on_coin_changed(value: float):
	SoundManager.set_coin_volume(value / 100.0)

func _on_jump_changed(value: float):
	SoundManager.set_jump_volume(value / 100.0)

func _show_group(group: Control):
	_hide_all_groups()
	menu_buttons.visible = false
	group.visible = true
	active_group = group

func show_menu():
	_hide_all_groups()
	menu_buttons.visible = true
	active_group = null

func _hide_all_groups():
	new_game_group.visible = false
	settings_group.visible = false
	credits_group.visible = false

func _on_start():
	var seed_text: String = $UI/NewGameGroup/SeedNewGame.text.strip_edges()
	if seed_text.is_empty():
		GameManager.current_seed = randi()
	else:
		GameManager.current_seed = seed_text.to_int()
	ScoreManager.reset_score()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_back():
	SoundManager.save_settings()
	get_tree().change_scene_to_file("res://scenes/menu_layer.tscn")
