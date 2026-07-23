extends State

var can_transition: bool = false

func enter():
	super.enter()
	
	# If player is dead when entering this state, transition out immediately!
	if not is_instance_valid(player):
		can_transition = true
		return

	animation_player.play("glowing")
	await dash()
	can_transition = true


func dash():
	# Double check player validity right before reading position
	if not is_instance_valid(player):
		return

	# Target position captured at the start of the dash
	var target_position = player.position

	var tween = create_tween()
	tween.tween_property(owner, "position", target_position, 0.8)
	await tween.finished


func transition():
	if can_transition:
		can_transition = false
		
		# If player exists, go back to Follow; otherwise fallback to an idle or static state
		if is_instance_valid(player):
			get_parent().change_state("Follow")
		else:
			# Optional: Change to "Idle" or keep him still if there's no player left to follow
			get_parent().change_state("Follow")
