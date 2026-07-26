extends State

@export var damage: int = 15  # Adjust this value in the Godot Inspector!

@onready var hitbox = $AttackHitbox
var can_transition

func enter():
	super.enter()
	hitbox.visible = false
	hitbox.monitoring = false
	animation_player.play("melee_attack")
	can_transition = false
	# Queue a timer
	await get_tree().create_timer(0.75).timeout
	# show hitbox
	hitbox.visible = true
	hitbox.monitoring = true
	await get_tree().create_timer(.1).timeout
	hitbox.visible = false
	hitbox.monitoring = false
	can_transition = true
	
	
	

func exit():
	super.exit()
	hitbox.visible = false
	hitbox.monitoring = false

func transition():
	if !can_transition:
		return
		
	if owner.direction.length() > 30:
		get_parent().change_state("Follow")

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if !body:
		return
	
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
