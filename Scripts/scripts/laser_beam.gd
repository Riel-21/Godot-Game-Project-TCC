extends State
@onready var laserhitbox: Area2D = $"../../Pivot/Laserhitbox"

@onready var pivot  = $"../../Pivot"
var can_transition: bool = false

func enter():
	super.enter()
	can_transition = false
	laserhitbox.visible = false
	laserhitbox.monitoring = false
	await play_animation("laser_cast")
	
	laserhitbox.visible = true
	laserhitbox.monitoring = true
	await play_animation("laser")
	laserhitbox.visible = false
	laserhitbox.monitoring = false
	can_transition = true

func exit():
	super.exit()
	laserhitbox.visible = false
	laserhitbox.monitoring = false


func play_animation(anim_name):
	animation_player.play(anim_name)
	await animation_player.animation_finished


func set_target():
	pivot.rotation = (owner.direction - pivot.position).angle()

func transition():
	if !can_transition:
		return
	if can_transition:
		can_transition = false
		laserhitbox.visible = false
		get_parent().change_state("Dash")
		







func _on_laserhitbox_body_entered(body: Node2D) -> void:
	if !body:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
