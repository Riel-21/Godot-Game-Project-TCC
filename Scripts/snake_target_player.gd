extends CharacterBody2D

@export var speed: float = 80.0
@export var damage_amount: int = 1

const MAX_HEALTH = 30
var health = MAX_HEALTH

@onready var health_bar: ProgressBar = $ProgressBar2

var player: Node2D = null


func _ready() -> void:
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = MAX_HEALTH
		health_bar.value = MAX_HEALTH
		health_bar.show()


func _physics_process(delta: float) -> void:
	# 1. Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Chase the player if detected
	if is_instance_valid(player):
		var direction_x = player.global_position.x - global_position.x
		
		if direction_x < 0:
			velocity.x = -speed
		elif direction_x > 0:
			velocity.x = speed
	else:
		velocity.x = 0

	# 3. Apply movement
	move_and_slide()


func take_damage(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, MAX_HEALTH)
	if health_bar:
		health_bar.value = health

	if health <= 0:
		if Engine.has_singleton("ScoreManager") or get_tree().root.has_node("ScoreManager"):
			ScoreManager.add_score(5)
		queue_free()


# Signals for DetectionArea
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

# Signals for Hitbox_attack
func _on_hitbox_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage() # Removed damage_amount to match Player script!
