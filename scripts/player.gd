extends CharacterBody2D

@export var SPEED: float = 1000.0
@export var JUMP_VELOCITY: float = -2500.0
@export var HEALTH: int = 1
@export var DEATH_FALL_DISTANCE: float = 2000

var dead: bool = false # true for death animation
var attack: bool = false
var last_safe_y: float = 0.0 
var attack_animation: String = "" # to prevent multiple attack animations at once

@onready var animated_sprite = $AnimatedSprite2D

var gravity_coefficient = 7.5

func _ready() -> void:
	last_safe_y = global_position.y

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

#	Ensures inputs are deactivated once player is dead.
	if dead:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_coefficient

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if not attack and Input.is_action_just_pressed("attack"):
		attack = true
		
		if is_on_floor():
			attack_animation = "player attack"
		else:
			attack_animation = "player jump_attack"

		animated_sprite.play(attack_animation)
	
	move_and_slide()
	
	if is_on_floor():
		last_safe_y = global_position.y
	
	if global_position.y > last_safe_y + DEATH_FALL_DISTANCE:
		HEALTH = 0
	
#	Handles the players death.
	if HEALTH <= 0:
		if not dead:
			dead = true
			animated_sprite.play("player death")
		return

# Handles the player animations
	if attack:
		animated_sprite.flip_h = direction < 0
		# End a jump attack when landing
		if attack_animation == "player jump_attack" and is_on_floor():
			var current_frame = animated_sprite.frame
			attack_animation = "player attack"
			animated_sprite.play(attack_animation)
			animated_sprite.frame = current_frame
	elif not is_on_floor(): 
		if animated_sprite.animation != "player jump":
			animated_sprite.play("player jump")
		animated_sprite.flip_h = direction < 0
	elif velocity.x != 0:
		if animated_sprite.animation != "player walk":
			animated_sprite.play("player walk")
		animated_sprite.flip_h = direction < 0
	else:
		if animated_sprite.animation != "player idle":
			animated_sprite.play("player idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "player attack" or animated_sprite.animation == "player jump_attack":
		attack = false
		attack_animation = ""

func apply_config(config) -> void:
	gravity_coefficient = config.gravity_coefficient
