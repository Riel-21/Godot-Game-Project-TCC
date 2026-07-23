extends CharacterBody2D

@onready var player = get_parent().find_child("player")
@onready var sprite = $Sprite2D
@onready var progress_bar: ProgressBar = $UI/ProgressBar


var direction : Vector2
var DEF = 0

var health = 100:
	set(value):
		health = value
		if progress_bar:
			progress_bar.value = value
		if value <= 0:
			if progress_bar:
				progress_bar.visible = false
			find_child("FiniteStateMachine").change_state("Death")
		elif value <= progress_bar.max_value / 2 and DEF == 0:
			DEF = 5
			find_child("FiniteStateMachine").change_state("ArmorBuff")


func _ready():
	set_physics_process(false)
	if progress_bar:
		progress_bar.max_value = health
		progress_bar.value = health


func _process(delta):
	# Safely check if player exists and hasn't been queued for deletion
	if not is_instance_valid(player):
		return # Stop execution if the player is freed!

	direction = player.position - position
	
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func _physics_process(delta):
	# Double check inside physics process too so velocity isn't updated toward a missing player
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	velocity = direction.normalized() * 40
	move_and_collide(velocity * delta)


# Updated to accept 'amount' from the bullet!
func take_damage(amount: int = 10):
	# Applies defense mitigation: reduces damage by DEF (minimum 1 damage taken)
	var final_damage = max(1, amount - DEF)
	health -= final_damage
