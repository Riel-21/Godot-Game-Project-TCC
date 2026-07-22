extends CharacterBody2D

@export var snake_poision_projectile_scene: PackedScene

@onready var health_bar: ProgressBar = $ProgressBar
@onready var spawn_point = $Marker2D

const MAX_HEALTH = 40
var health = MAX_HEALTH

var player = null
var player_in_range = false


func _ready():
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = MAX_HEALTH
		health_bar.value = MAX_HEALTH
		health_bar.show()


func _physics_process(delta: float) -> void:
	# Keep basic gravity so the enemy sits on the ground
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = 0
	move_and_slide()


func take_damage(amount):
	health -= amount
	health = clamp(health, 0, MAX_HEALTH)
	if health_bar:
		health_bar.value = health

	if health <= 0:
		ScoreManager.add_score(5)
		queue_free()


func shoot():
	if not is_instance_valid(player) or snake_poision_projectile_scene == null:
		return

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
