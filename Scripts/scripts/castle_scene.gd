extends Node2D

@onready var pause_menu: CanvasLayer = $Pause_menu
var paused = false

func _ready() -> void:
	# Ensure the pause menu is hidden when the game starts
	pause_menu.hide()

func _input(_event: InputEvent) -> void:
	# This replaces the need to check in _process() every single frame
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	paused = !paused
	
	# 1. Tell the engine whether to stop or start processing game loops
	get_tree().paused = paused
	
	# 2. Show or hide the pause menu UI accordingly
	if paused:
		pause_menu.show()
	else:
		pause_menu.hide() # Or pause_menu.hide() depending on your UI functions




  




func _on_changesceneboss_body_entered(body: Node2D):
	get_tree().change_scene_to_file.call_deferred("res://scenes/boss_room.tscn")
