extends Area2D

@onready var game_manager = get_node("/root/Game/GameManager") # might break, but % does not work.

func _on_body_entered(_body: Node2D) -> void:
	set_deferred("monitoring", false)
	game_manager.add_to_score()
	
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "position", self.position + Vector2(0, -300), 1)
	tween.tween_property(self, "modulate:a", 0, 1)
	
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
