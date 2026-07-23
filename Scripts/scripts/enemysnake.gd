extends CharacterBody2D

const speed = 20

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _physics_process(_delta: float) -> void:
	# Added an early return: If the player is dead/freed, stop trying to navigate to them
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()

func makepath() -> void:
	# is_instance_valid checks if the node exists and hasn't been deleted
	if is_instance_valid(player):
		nav_agent.target_position = player.global_position

func _on_timer_timeout() -> void:
	makepath()
