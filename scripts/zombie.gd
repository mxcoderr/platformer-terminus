extends CharacterBody2D
class_name Zombie

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

var health: int = 1
var direction: float = 1.0
var attacking: bool = false
var player: CharacterBody2D

@onready var zombie_sprite = find_child("zombie_*_sprite", true, false)
var floor_checker: RayCast2D

var gravity_coefficient: float = 1.0

func _ready() -> void:
	floor_checker = $FloorChecker
	if gravity_coefficient < 0:
		floor_checker.position.x *= -1
	if GameManager.DEBUG_ZOMBIE:
		print("Zombie: ", self.name)
		print("  visible: ", visible)
		print("  position: ", global_position)
		print("  sprite: ", zombie_sprite)
		print("  sprite visible: ", zombie_sprite.visible)
		print("  sprite position: ", zombie_sprite.position)
		print("  animation: ", zombie_sprite.animation)
		print("  player position: ", player.global_position)

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
		if GameManager.DEBUG_ZOMBIE:
			print("Player dies to zombie: " + self.name)
		body.HEALTH -= 1

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_die()

func _die() -> void:
	zombie_sprite.play("dead")
	
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "position", self.position + Vector2(0, -300), 1)
	tween.tween_property(self, "modulate:a", 0, 1)
	
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
	
