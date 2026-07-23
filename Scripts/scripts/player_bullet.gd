extends Area2D

var direction = Vector2.RIGHT
var speed = 300
@export var damage_amount: int = 15 #Set bullet damage here

func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	# Only try to damage things that actually have a take_damage method (like enemies)
	body.take_damage()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
