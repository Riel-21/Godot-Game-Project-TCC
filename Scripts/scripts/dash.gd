extends State

@export var damage: int = 25  # Damage value adjustable in Inspector

var can_transition: bool = false

func enter():
	super.enter()
	can_transition = false
	
	# Fetch player if null
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	# If player is STILL missing/dead, wait half a second before allowing state exit
	if not is_instance_valid(player):
		await get_tree().create_timer(0.5).timeout
		can_transition = true
		return

	if animation_player.has_animation("glowing"):
		animation_player.play("glowing")
	
	await dash()
	can_transition = true

func dash():
	if not is_instance_valid(player):
		return

	var target_position = player.position
	var tween = create_tween()
	
	# Move towards the player's last position over 0.8 seconds
	tween.tween_property(owner, "position", target_position, 0.8)
	await tween.finished


func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")


# Ensure transition gets checked in case _physics_process drives the FSM
func physics_update(delta: float):
	if can_transition:
		transition()


func _on_boss_hitbox_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
