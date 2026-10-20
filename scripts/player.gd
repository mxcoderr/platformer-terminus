extends CharacterBody2D

@export var SPEED: float = 1000.0
@export var JUMP_VELOCITY: float = -2500.0
@export var HEALTH: int = 1
var attack: bool = false

@onready var animated_sprite = $AnimatedSprite2D

var gravity_coefficient = 7.5

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_coefficient

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if !attack and Input.is_key_pressed(KEY_ENTER):
		animated_sprite.play("player attack")
	
	move_and_slide()
	
#	Handles the player animations
	if !attack:
		if velocity.x != 0:
			animated_sprite.play("player walk")
			animated_sprite.flip_h = direction < 0
		else:
			animated_sprite.play("player idle")
			
		if velocity.y != 0:
			animated_sprite.play("player jump")
			
		if HEALTH < 1:
			animated_sprite.play("player death")

func apply_config(config) -> void:
	gravity_coefficient = config.gravity_coefficient
