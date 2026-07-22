extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $Area2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

var attack_mode = false
var is_attacking = false


func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get movement input.
	var direction := Input.get_axis("move left", "move right")

	# Flip sprite & hitbox.
	if direction > 0:
		animated_sprite_2d.flip_h = false
		attack_hitbox.scale.x = 1
	
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		attack_hitbox.scale.x = -1

	# Toggle attack mode with F.
	if Input.is_action_just_pressed("toggle attack mode"):
		attack_mode = !attack_mode

	# Attack with Q.
	if attack_mode and Input.is_action_just_pressed("attack") and !is_attacking:
		attack()

	# Movement.
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Don't change animations while attacking.
	if is_attacking:
		return

	# Animations.
	if is_on_floor():
		if direction == 0:
			if attack_mode:
				animated_sprite_2d.play("idle attack")
			else:
				animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")


func attack():
	is_attacking = true
	animated_sprite_2d.play("attack")
	
	await get_tree().create_timer(0.14).timeout
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.14).timeout
	attack_hitbox.monitoring = false
	
	await get_tree().create_timer(0.15).timeout

	is_attacking = false
	print("DEBUG: Attack finished! is_attacking is now back to FALSE.")

	if attack_mode:
		animated_sprite_2d.play("idle attack")
	else:
		animated_sprite_2d.play("idle")



func _on_sword_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(15)


var hearts_list : Array[TextureRect]
var health = 5

func _ready():
	# Hitbox starts disable
	attack_hitbox.monitoring = false

	# Setup hearts display
	var hearts_parent = $"health bar/HBoxContainer"
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	print(hearts_list)

func take_damage():
	if health > 0:
		health -= 1
		update_heart_display()
		
func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health
