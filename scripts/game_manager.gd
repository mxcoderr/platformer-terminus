extends Node

var score: int = 0
@onready var score_label = get_node("../Level/Background/CoinsPicked")

func add_to_score():
	score += 1
	score_label.text = str(score) + " Coins"
