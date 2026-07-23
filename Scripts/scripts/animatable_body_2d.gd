extends AnimatableBody2D


@export var fullswing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if fullswing:
		$AnimationPlayer.play("fullswing")
