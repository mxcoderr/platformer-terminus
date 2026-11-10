extends CharacterBody2D

const JUMP_SFX := preload("res://assets/sounds/jump.mp3")
const ATTACK_SFX := preload("res://assets/sounds/attack_hit.mp3")

@onready var level_config: Node = get_node("..")
@export var SPEED: float = 1000.0
@export var JUMP_VELOCITY: float = -2500.0
@export var HEALTH: int = 1
@export var DEATH_FALL_DISTANCE: float = 2000

var dead: bool = false # true for death animation
var attack: bool = false
var last_safe_y: float = 0.0 
var attack_animation: String = "" # to prevent multiple attack animations at once

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox

var active_effects: Array[bool]
var base_hitbox_position: Vector2
var base_up_direction: Vector2
var gravity_coefficient: float

func _on_elixir_activated(elixir_type: int) -> void:
	active_effects[elixir_type] = not active_effects[elixir_type]
	
	if elixir_type == 0:
		if active_effects[elixir_type]:
			JUMP_VELOCITY *= level_config.jump_elixir_factor
		else:
			JUMP_VELOCITY /= level_config.jump_elixir_factor
	elif elixir_type == 1:
		if active_effects[elixir_type]:
			SPEED *= level_config.movement_elixir_factor
		else:
			SPEED /= level_config.movement_elixir_factor
	elif elixir_type == 2:
		up_direction.y *= -1

func _ready() -> void:
	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_attack_hit)
	
	active_effects.resize(level_config.ElixirType.values().size())
	active_effects.fill(false)
	
	last_safe_y = global_position.y
	
	base_up_direction = up_direction
	base_hitbox_position = $PlayerCollision.position

func _physics_process(delta: float) -> void:
	gravity_coefficient = level_config.gravity_coefficient
	if not (base_up_direction == up_direction):
		onGravityFlipped()
	$PlayerCollision.position.y = base_hitbox_position.y
	
	var direction := Input.get_axis("move_left", "move_right")

	# Ensures inputs are deactivated once player is dead.
	if dead:
		return
	
	velocity += get_gravity() * gravity_coefficient * -up_direction.y * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		SoundManager.play_jump()
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if not attack and Input.is_action_just_pressed("attack"):
		_start_attack()
	
	move_and_slide()
	
	if is_on_floor():
		last_safe_y = global_position.y
	
	if up_direction == Vector2.UP:
		if global_position.y - last_safe_y > DEATH_FALL_DISTANCE:
			if GameManager.DEBUG_PLAYER:
				print("FALL DEATH: y=", global_position.y, " last_safe_y=", last_safe_y)
			HEALTH = 0
	else:
		if last_safe_y - global_position.y > DEATH_FALL_DISTANCE:
			if GameManager.DEBUG_PLAYER:
				print("FALL DEATH (FLIP): y=", global_position.y, " last_safe_y=", last_safe_y)
			HEALTH = 0
	
#	Handles the players death.
	if HEALTH <= 0:
		if not dead:
			dead = true
			animated_sprite.play("player death")
			_on_death()
		return

# Handles the player animations
	if attack:
		if direction != 0:
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
		if direction != 0:
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
		attack_hitbox.monitoring = false

func apply_config(config) -> void:
	gravity_coefficient = config.gravity_coefficient

func onGravityFlipped():
	JUMP_VELOCITY *= -1
	animated_sprite.flip_v = up_direction == Vector2.DOWN
	base_hitbox_position.y *= -1
	base_up_direction = up_direction

func _on_death():
	if GameManager.DEBUG_PLAYER:
		print("DIED! HEALTH=", HEALTH, " y=", global_position.y, " last_safe_y=", last_safe_y)
	GameManager.player_died = true
	get_tree().change_scene_to_file("res://scenes/menu_layer.tscn")

func _on_attack_hit(body):
	if body is Zombie:
		if GameManager.DEBUG_ZOMBIE:
			print("Zombie hit: ", body.name)
		body.take_damage(1)

func _start_attack():
	SoundManager.play_attack()
	attack = true
	attack_hitbox.monitoring = true
	
	if is_on_floor():
		attack_animation = "player attack"
	else:
		attack_animation = "player jump_attack"
	
	animated_sprite.play(attack_animation)
