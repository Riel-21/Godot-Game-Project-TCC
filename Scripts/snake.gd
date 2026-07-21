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
