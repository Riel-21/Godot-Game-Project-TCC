extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

var player: Node2D = null
var acceleration: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Safely grab the player from anywhere in the scene tree
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# 2. Homing steering math
	acceleration = (player.position - position).normalized() * 700
	
	velocity += acceleration * delta
	rotation = velocity.angle()
	
	velocity = velocity.limit_length(150)
	
	position += velocity * delta

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
