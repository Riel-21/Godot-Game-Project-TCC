extends State

@export var damage: int = 15  # Adjust this value in the Godot Inspector!

@onready var hitbox = $AttackHitbox
var can_transition

func enter():
	super.enter()
	hitbox.visible = false
	animation_player.play("melee_attack")
	can_transition = false
	# Queue a timer
	await get_tree().create_timer(1).timeout
	# show hitbox
	hitbox.visible = true
	await get_tree().create_timer(.1).timeout
	
	can_transition = true
	

# func connected to melee collider signal
	# Do damage


func transition():
	if !can_transition:
		return
		
	if owner.direction.length() > 30:
		get_parent().change_state("Follow")




func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
