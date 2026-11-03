extends Control

@onready var show_score: Control = $UI/ShowScoreGroup
@onready var new_score_group: Control = $UI/NewScoreGroup
@onready var score_label: Label = $UI/NewScoreGroup/ScoreLabelNewScore
@onready var name_input: LineEdit = $UI/NewScoreGroup/NameNewScore
@onready var show_btn: Button = $UI/NewScoreGroup/ContinueNewScore
@onready var rows: VBoxContainer = $UI/ShowScoreGroup/VBoxContainer/Rows
@onready var name_label: Label = $UI/NewScoreGroup/NameLabelNewScore
@onready var show_main: Button = $UI/ShowScoreGroup/ContinueShowScore

func _ready():
	if GameManager.player_died:
		visible = true
	else:
		visible = false
		
	score_label.text = "Score: " + str(ScoreManager.get_score())
	show_btn.pressed.connect(_on_show)
	show_main.pressed.connect(_on_continue)
	
	ScoreManager.highscore_table_changed.connect(_refresh)
	_show_new_score()

func _show_new_score():
	new_score_group.visible = true
	show_score.visible = false

func _show_table():
	new_score_group.visible = false
	show_score.visible = true
	_refresh()

func _on_show():
	var player_name: String = name_input.text.strip_edges()
	if player_name.is_empty():
		player_name = "Anonym"
	ScoreManager.submit_score(player_name)
	_show_table()

func _on_continue():
	visible = false
	get_parent().show_menu()

func _refresh():
	for child in rows.get_children():
		child.queue_free()

	var scores: Array = ScoreManager.get_highscores()
	for i in scores.size():
		var row := HBoxContainer.new()

		var rank := Label.new()
		rank.text = "%d." % (i + 1)
		rank.custom_minimum_size.x = 30

		var label_name := Label.new()
		label_name.text = scores[i]["name"]
		label_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var pts := Label.new()
		pts.text = str(int(scores[i]["score"]))

		row.add_child(rank)
		row.add_child(label_name)
		row.add_child(pts)
		rows.add_child(row)
