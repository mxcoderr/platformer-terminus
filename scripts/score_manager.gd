extends Node

signal score_changed(new_score: int)
signal coins_changed(new_coins: int)

var _coins = 0
var _score = 0
func _ready():
	print("ScoreManager is active")
	
func score(obj):
	if obj.get_script().get_global_name() == "Coin":
		_coins += 1
		_score += 1
		score_changed.emit(_score)
		coins_changed.emit(_coins)
	

func get_coins():
	return _coins

func get_score():
	return _score
