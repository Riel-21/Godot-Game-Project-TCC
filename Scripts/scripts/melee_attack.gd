extends State

@export var damage: int = 15  # Adjust this value in the Godot Inspector!


func enter():
	super.enter()
	animation_player.play("melee_attack")
	
	


func _on_melee_hitbox_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)


func transition():
	# Safely check if owner and player exist before checking distance
	if is_instance_valid(owner) and is_instance_valid(player):
		if owner.direction.length() > 30:
			get_parent().change_state("Follow")
	else:
		# Fallback if player is dead/freed
		get_parent().change_state("Follow")
