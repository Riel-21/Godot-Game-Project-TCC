extends Area2D

var direction = Vector2.RIGHT
var speed = 300
@export var damage_amount: int = 15 #Set bullet damage here

func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	# Only try to damage things that actually have a take_damage method (like enemies)
	if body.has_method("take_damage"):
		body.take_damage(damage_amount)
	else:
		if body.is_in_group("snake"):
			body.take_damage(damage_amount)
	# Whether it hit an enemy or a TileMap wall, the bullet should always delete itself on impact
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
