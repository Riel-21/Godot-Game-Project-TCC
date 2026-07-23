extends Area2D

@onready var timer: Timer = $"../Timer"


func _on_body_entered(body: Node2D) -> void:
	# Check if the body that touched us is in the "player" group
	if body.is_in_group("player"):
		queue_free()
		timer.start()
		




func _on_timer_timeout():
	get_tree().reload_current_scene()
