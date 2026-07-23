extends CanvasLayer

# Define a custom signal that other scenes can listen for
signal resumed

@onready var main_buttons: VBoxContainer = $Control/VBoxContainer

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()
	resumed.emit() # Tell the main scene "Hey, we unpaused!"

func _on_quit_pressed() -> void:
	get_tree().quit()
