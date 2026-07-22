extends CharacterBody2D

@onready var health_bar: ProgressBar = $ProgressBar

const MAX_HEALTH = 50
var health = MAX_HEALTH

func _ready():
	# Setup health bar
	health_bar.min_value = 0
	health_bar.max_value = MAX_HEALTH
	health_bar.value = MAX_HEALTH
	health_bar.show()


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func take_damage(amount):
	print("I GOT HIT!")
	print("Health before:", health)

	health -= amount
	health = clamp(health, 0, MAX_HEALTH)

	print("Health after:", health)

	health_bar.value = health
	print("ProgressBar value:", health_bar.value)

	if health <= 0:
		queue_free()

@export var snake_poision_projectile_scene: PackedScene

@onready var spawn_point = $Marker2D

var player = null
var player_in_range = false


func shoot():
	print("Shoot")
	var projectile = snake_poision_projectile_scene.instantiate()

	projectile.global_position = spawn_point.global_position

	projectile.direction = (player.global_position - $Marker2D.global_position).normalized()

	get_tree().current_scene.add_child(projectile)


func _on_timer_timeout() -> void:
	print("Timer fired")
	if player_in_range:
		print("Trying to shoot")
		shoot()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Something entered:", body.name)
	if body.is_in_group("Player"):
		player = body
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_in_range = false
