extends Area2D

@export var speed = 200

var direction = Vector2.ZERO


func _process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	# Ignore other snakes / enemies
	if body.is_in_group("enemies") or (body is CharacterBody2D and not body.is_in_group("player")):
		return

	if body.is_in_group("player") or body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage()
			
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
