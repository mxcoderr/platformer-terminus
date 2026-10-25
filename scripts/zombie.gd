extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var direction = 1.0
var attacking = false
var player: CharacterBody2D

@onready var zombie_sprite = find_child("zombie_*_sprite", true, false)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	if !($FloorChecker.is_colliding()) or is_on_wall():
		direction *= -1
		zombie_sprite.flip_h = (direction == -1)
		$FloorChecker.position.x *= -1
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# animations
	if velocity.x != 0:
		zombie_sprite.play("walk")
		zombie_sprite.flip_h = direction < 0

	move_and_slide()

func apply_config(player_node: CharacterBody2D) -> void:
	player = player_node

func _on_collision_body_entered(body: Node2D) -> void:
	if body == player:
		body.HEALTH -= 1
