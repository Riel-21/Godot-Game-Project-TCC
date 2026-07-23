extends StaticBody2D

@onready var timer: Timer = $VanishTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

# Duration before the platform vanishes after being stepped on
@export var vanish_delay: float = 1.0
# Duration before the platform automatically reappears (set to 0 to never respawn)
@export var respawn_delay: float = 3.0 

func _ready() -> void:
	# Make sure the timer only runs once per trigger
	timer.one_shot = true
	# Connect the timer's timeout signal to our vanish function
	timer.timeout.connect(_on_vanish_timeout)

func _on_vanish_timeout() -> void:
	# Disable collision and hide the platform safely
	collision_shape.set_deferred("disabled", true)
	sprite.visible = false
	
	# Handle respawn if desired
	if respawn_delay > 0.0:
		await get_tree().create_timer(respawn_delay).timeout
		respawn_platform()

func respawn_platform() -> void:
	collision_shape.set_deferred("disabled", false)
	sprite.visible = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if the player stepped on the platform
	if body.is_in_group("Player") and timer.is_stopped():
		timer.start(vanish_delay)
