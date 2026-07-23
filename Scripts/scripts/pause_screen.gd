extends Control

@onready var mainbuttons: VBoxContainer = $VBoxContainer


func _ready():
	mainbuttons.visible = true


func _process(_delta):
	pass


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false



func _on_quit_pressed():
	#save first then quit for later
	get_tree().quit()
	
	
