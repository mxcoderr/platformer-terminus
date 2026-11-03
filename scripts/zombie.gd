extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var direction = 1.0
var attacking = false
var player: CharacterBody2D

@onready var zombie_sprite = find_child("zombie_*_sprite", true, false)
var floor_checker: RayCast2D

var gravity_coefficient: float = 1.0

func _ready() -> void:
	floor_checker = $FloorChecker
	if gravity_coefficient < 0:
		floor_checker.position.x *= -1

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * gravity_coefficient * delta
	
	if !(floor_checker.is_colliding()) or is_on_wall():
		direction *= -1
		floor_checker.position.x *= -1
	
	velocity.x = direction * SPEED

	# animations
	if velocity.x != 0:
		zombie_sprite.play("walk")
		if gravity_coefficient > 0:
			zombie_sprite.flip_h = direction < 0
		else:
			zombie_sprite.flip_h = direction > 0

	move_and_slide()

func apply_config(player_node: CharacterBody2D) -> void:
	player = player_node

func _on_collision_body_entered(body: Node2D) -> void:
	if body == player:
		body.HEALTH -= 1
