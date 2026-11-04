extends Area2D
class_name Coin

var animatedSprite: AnimatedSprite2D

func _ready() -> void:
	animatedSprite = $"Sprite"

func _on_body_entered(_body: Node2D) -> void:
	SoundManager.play_coin()
	set_deferred("monitoring", false)
	ScoreManager.score(self)
	
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "position", self.position + Vector2(0, -300), 1)
	tween.tween_property(self, "modulate:a", 0, 1)
	
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
