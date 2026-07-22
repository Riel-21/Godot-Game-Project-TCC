extends CharacterBody2D

const speed = 60.0 # Increased speed slightly so movement is visible

@onready var health_bar: ProgressBar = $ProgressBar
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var spawn_point = $Marker2D

const MAX_HEALTH = 40
var health = MAX_HEALTH

@export var snake_poision_projectile_scene: PackedScene

var player = null
var player_in_range = false


func _ready():
	# Setup health bar
	health_bar.min_value = 0
	health_bar.max_value = MAX_HEALTH
	health_bar.value = MAX_HEALTH
	health_bar.show()


func _physics_process(delta: float) -> void:
	# If player hasn't been detected yet, do not follow
	if not is_instance_valid(player):
		velocity.x = 0
		move_and_slide()
		return

	# Apply gravity if in the air
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Godot 4 NavigationAgent calculation
	var next_path_pos = nav_agent.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()
	
	velocity.x = dir.x * speed

	move_and_slide()


func makepath() -> void:
	if is_instance_valid(player):
		nav_agent.target_position = player.global_position


func take_damage(amount):
	health -= amount
	health = clamp(health, 0, MAX_HEALTH)
	health_bar.value = health

	if health <= 0:
		ScoreManager.add_score(5) 
		queue_free()


func shoot():
	if not is_instance_valid(player):
		return
		
	print("Shoot")
	var projectile = snake_poision_projectile_scene.instantiate()
	projectile.global_position = spawn_point.global_position
	projectile.direction = (player.global_position - spawn_point.global_position).normalized()
	get_tree().current_scene.add_child(projectile)


func _on_timer_timeout() -> void:
	if player_in_range:
		shoot()


func _on_area_2d_body_entered(body: Node2D) -> void:
	# Checks for both "player" and "Player" to prevent group naming bugs
	if body.is_in_group("player") or body.is_in_group("Player"):
		player = body
		player_in_range = true
		makepath() # Instantly start calculating path when detected!


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_in_range = false


func _on_timer_for_nav_timeout() -> void:
	makepath()
