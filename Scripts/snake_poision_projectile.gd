extends Area2D

@export var speed = 200

var direction = Vector2.ZERO


func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
