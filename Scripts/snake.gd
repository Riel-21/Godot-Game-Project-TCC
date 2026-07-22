extends CharacterBody2D

@export var snake_poision_projectile_scene: PackedScene
@onready var health_bar: ProgressBar = $ProgressBar
@onready var spawn_point = $Marker2D

const MAX_HEALTH = 40
var health = MAX_HEALTH
var speed = 60.0

var direction = 0
var player_pos = Vector2.ZERO
var target_pos = Vector2.ZERO

var player = null 
var player_in_range = false


func _ready():
	# Setup health bar
	health_bar.min_value = 0
	health_bar.max_value = MAX_HEALTH
	health_bar.value = MAX_HEALTH
	health_bar.show()


func _physics_process(delta: float) -> void:
	# 1. Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Movement logic towards player
	if is_instance_valid(player):
		player_pos = player.global_position
		target_pos = (player_pos - global_position).normalized()
		velocity.x = target_pos.x * speed
	else:
		velocity.x = 0

	# 3. Apply physics movement
	move_and_slide()


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
	if body.is_in_group("player") or body.is_in_group("Player"):
		player = body
		player_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_in_range = false
