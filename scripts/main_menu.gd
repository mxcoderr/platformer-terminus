extends Control

@onready var menu_buttons: Control = $UI/MainGroup/MenuButtons
@onready var new_game_group: Control = $UI/NewGameGroup
@onready var settings_group: Control = $UI/SettingsGroup
@onready var credits_group: Control = $UI/CreditsGroup

var active_group: Control = null

func _ready():
	#SoundManager.play_bgm(preload("res://assets/sounds/background_music.mp3"))
	
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
