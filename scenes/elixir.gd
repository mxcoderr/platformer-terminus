extends Area2D

var type: LevelConfig.ElixirType

var idle_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# idle animation
	idle_tween = create_tween().set_loops()
	idle_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.tween_property(self, "position:y", -20.0, 1.0).as_relative()
	idle_tween.tween_property(self, "position:y", 20.0, 1.0).as_relative()

func _on_body_entered(_body: Node2D) -> void:
	print("Collect elixir")
	if idle_tween:
		idle_tween.kill()
	
	set_deferred("monitoring", false)
	
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "position", self.position + Vector2(0, -300), 1)
	tween.tween_property(self, "modulate:a", 0, 1)
	
	tween.set_parallel(false)
	tween.tween_callback(queue_free)	

func initialize(givenType: LevelConfig.ElixirType):
	type = givenType
	#if type == 1:
		#$Texture.modulate = 
	print("Got a type : ", type)
