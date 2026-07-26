extends Node2D

var current_state: State
var previous_state: State

func _ready():
	current_state = get_child(0) as State
	previous_state = current_state
	current_state.enter()

func change_state(state_name: String):
	# 1. Look for matching state child (case-insensitive search)
	var new_state: State = null
	for child in get_children():
		if child.name.nocasecmp_to(state_name) == 0:
			new_state = child as State
			break
			
	# 2. Safety check if state doesn't exist
	if not new_state:
		push_error("State machine couldn't find state: " + state_name)
		return
		
	# 3. Exit the old state FIRST
	if current_state:
		current_state.exit()
		
	# 4. Enter the new state
	previous_state = current_state
	current_state = new_state
	current_state.enter()
