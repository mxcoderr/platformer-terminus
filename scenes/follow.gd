extends Camera2D

@export var target : Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_transform.origin = global_transform.origin.lerp(
		target.global_transform.origin, 0.1
	)
