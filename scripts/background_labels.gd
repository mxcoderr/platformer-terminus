extends CanvasLayer

@onready var coin_label: Label = $CoinCounter
@onready var score_label: Label = $ScoreCounter

func _ready():
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.coins_changed.connect(_on_coins_changed)
	_on_score_changed(ScoreManager.get_score())
	_on_coins_changed(ScoreManager.get_coins())

func _on_score_changed(new_score: int):
	score_label.text = str(new_score) + " Score"

func _on_coins_changed(new_coins: int):
	coin_label.text = str(new_coins) + " Coins"
