extends Node

signal score_changed(new_score: int)
signal coins_changed(new_coins: int)
signal highscore_table_changed()

var _coins = 0
var _score = 0
var highscores: Array = []

const SAVE_PATH := "user://highscores.json"
const MAX_ENTRIES := 5

func _ready():
	if GameManager.DEBUG:
		print("ScoreManager is active")
	_load()

func _exit_tree():
	_save()

func score(obj):
	if obj.get_script().get_global_name() == "Coin":
		_coins += 1
		_score += 1
		score_changed.emit(_score)
		coins_changed.emit(_coins)

func get_coins() -> int:
	return _coins

func get_score() -> int:
	return _score

func reset_score() -> void:
	_score = 0
	_coins = 0
	score_changed.emit(_score)
	coins_changed.emit(_coins)

func submit_score(player_name: String) -> bool:
	if _score <= 0:
		return false

	var entry := {
		"name": player_name,
		"score": _score,
		"date": Time.get_datetime_string_from_system(),
	}

	highscores.append(entry)
	highscores.sort_custom(func(a, b): return a["score"] > b["score"])

	if highscores.size() > MAX_ENTRIES:
		highscores = highscores.slice(0, MAX_ENTRIES)

	_save()
	highscore_table_changed.emit()
	return true

func get_highscores() -> Array:
	return highscores.duplicate()

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(highscores, "\t"))
		file.close()

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if parsed is Array:
			highscores = parsed
