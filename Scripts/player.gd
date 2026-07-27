extends CharacterBody2D

# --- NODES & REFERENCES ---
@export var bullet_node: PackedScene
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_jumptimer: Timer = $CoyoteJumptimer
@onready var jump_buffer_timer: Timer = $jump_buffer_timer
@onready var pause_menu: Control = $Pause_menu/Pause_screen
@onready var dash_timer: Timer = $DashTimer

# Combat & Hitbox References
@onready var attack_hitbox: Area2D = $Area2D
@onready var hurt_hitbox: CollisionShape2D = $HurtHitbox

# --- MOVEMENT CONSTANTS ---
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_CUTOFF = 0.5 

# Wall Jump Tuning
const WALL_JUMP_VELOCITY_Y = -320.0   
const WALL_JUMP_PUSHBACK_X = 280.0   
const WALL_JUMP_CONTROL_HALT = 0.15  

# Double Jump Tuning
const MAX_JUMPS = 2
var jumps_remaining: int = MAX_JUMPS

# Dash Tuning
const DASH_SPEED = 500.0       
const DASH_DURATION = 0.2      

# Movement State Variables
var is_wall_jumping: bool = false
var wall_jump_timer: float = 0.0
const wall_slide_gravity = 100.0
var is_wall_sliding = false

var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: float = 0.0

# --- COMBAT & HEALTH VARIABLES ---
var attack_mode: bool = false
var is_attacking: bool = false

var health: int = 5
var hearts_list: Array[TextureRect] = []


func _ready() -> void:
	add_to_group("player")
	
	# Setup UI & Timers
	if pause_menu:
		pause_menu.visible = false
		
	coyote_jumptimer.one_shot = true
	coyote_jumptimer.wait_time = 0.15
	
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.wait_time = 0.1
	
	dash_timer.one_shot = true
	dash_timer.wait_time = DASH_DURATION
	dash_timer.timeout.connect(_on_dash_timer_timeout)

	# Combat Setup
	if is_instance_valid(attack_hitbox):
		attack_hitbox.monitoring = false

	# Setup Heart Container UI
	var hearts_parent = get_node_or_null("health bar/HBoxContainer")
	if hearts_parent:
		for child in hearts_parent.get_children():
			if child is TextureRect:
				hearts_list.append(child)
		update_heart_display()


func _physics_process(delta: float) -> void:
	# Capture horizontal direction input
	var direction := Input.get_axis("ui_left", "ui_right")

	# --- HANDLE DASH TRIGGER ---
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash(direction)

	# --- DASH OVERRIDE MODE ---
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0 
		move_and_slide()
		return 

	# 1. Apply Gravity (Only if we aren't wall sliding)
	if not is_on_floor() and not is_wall_sliding:
		velocity += get_gravity() * delta

	# 2. Reset Jumps when Grounded or Wall Sliding
	if is_on_floor() or is_on_wall_only():
		jumps_remaining = MAX_JUMPS

	# 3. Manage Wall Jump Control Lock
	if is_wall_jumping:
		wall_jump_timer -= delta
		if wall_jump_timer <= 0:
			is_wall_jumping = false

	# 4. Capture Jump Input (Jump Buffer)
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()

	# 5. Determine Jump Intentions
	var wants_to_jump = Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump") or !jump_buffer_timer.is_stopped()
	var can_ground_jump = is_on_floor() or coyote_jumptimer.time_left > 0.0
	var can_wall_jump = is_on_wall_only()

	# 6. Normal Ground Jump / Coyote Jump
	if wants_to_jump and can_ground_jump:
		velocity.y = JUMP_VELOCITY
		jumps_remaining = MAX_JUMPS - 1
		coyote_jumptimer.stop() 
		jump_buffer_timer.stop()

	# 7. Wall Jump
	elif wants_to_jump and can_wall_jump:
		var wall_normal = get_wall_normal()
		velocity.y = WALL_JUMP_VELOCITY_Y
		velocity.x = wall_normal.x * WALL_JUMP_PUSHBACK_X
		
		is_wall_jumping = true
		wall_jump_timer = WALL_JUMP_CONTROL_HALT
		
		jumps_remaining = MAX_JUMPS - 1
		jump_buffer_timer.stop()
		coyote_jumptimer.stop()
		is_wall_sliding = false

	# 8. Air Jump (Double Jump)
	elif wants_to_jump and jumps_remaining > 0:
		velocity.y = JUMP_VELOCITY
		jumps_remaining -= 1
		jump_buffer_timer.stop()

	# 9. Variable Jump Height Cutoff
	if (Input.is_action_just_released("ui_accept") or Input.is_action_just_released("jump")) and velocity.y < 0:
		velocity.y *= JUMP_CUTOFF

	# 10. Horizontal Movement
	if not is_wall_jumping:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta * 2)

	# 11. Flip Sprites & Hitboxes based on facing direction
	if direction > 0:
		animated_sprite_2d.flip_h = false
		if attack_hitbox: attack_hitbox.scale.x = 1
		if hurt_hitbox: hurt_hitbox.scale.x = 1
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		if attack_hitbox: attack_hitbox.scale.x = -1
		if hurt_hitbox: hurt_hitbox.scale.x = -1

	# 12. Toggle Attack Mode
	if Input.is_action_just_pressed("toggle attack mode"):
		attack_mode = !attack_mode

	# 13. Attack Trigger
	if attack_mode and Input.is_action_just_pressed("attack") and !is_attacking:
		attack()

	# 14. Wall Slide physics
	wall_slide(delta)

	# 15. Animations
	handle_animation(direction)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	# Coyote Time Ledge Tracking
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jumptimer.start()
		if jumps_remaining == MAX_JUMPS:
			jumps_remaining = MAX_JUMPS - 1
		
	if is_on_floor():
		can_dash = true


# --- COMBAT FUNCTIONS ---
func attack():
	is_attacking = true
	animated_sprite_2d.play("attack")
	
	await get_tree().create_timer(0.14).timeout
	if attack_hitbox: attack_hitbox.monitoring = true
	
	await get_tree().create_timer(0.14).timeout
	if attack_hitbox: attack_hitbox.monitoring = false
	
	await get_tree().create_timer(0.15).timeout

	is_attacking = false

	if attack_mode:
		animated_sprite_2d.play("idle attack")
	else:
		animated_sprite_2d.play("idle")


func _on_sword_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not body.is_in_group("player"):
		body.take_damage(15)


# --- HEALTH & HEART UI ---
func take_damage(amount: int = 1):
	if health > 0:
		health -= amount
		health = clamp(health, 0, 5)
		update_heart_display()
		
		if health <= 0:
			die()

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health

func die():
	set_physics_process(false)
	set_process_input(false)
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()


# --- ANIMATION & UTILITY ---
func handle_animation(direction: float):
	if is_dashing or is_attacking:
		return

	if is_on_floor():
		if direction == 0:
			if attack_mode:
				animated_sprite_2d.play("idle attack")
			else:
				animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		if is_on_wall_only():
			animated_sprite_2d.play("idle") 
		else:
			animated_sprite_2d.play("jump")

func wall_slide(delta):
	if is_on_wall() and not is_on_floor():
		var wall_normal = get_wall_normal()
		var is_pressing_into_wall = (wall_normal.x < 0 and Input.is_action_pressed("ui_right")) or (wall_normal.x > 0 and Input.is_action_pressed("ui_left"))
		
		if is_pressing_into_wall:
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
		
	if is_wall_sliding:
		velocity.y = move_toward(velocity.y, wall_slide_gravity, wall_slide_gravity * delta * 10)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
		
func toggle_pause():
	if pause_menu:
		get_tree().paused = !get_tree().paused
		pause_menu.visible = get_tree().paused

func start_dash(dir: float) -> void:
	is_dashing = true
	can_dash = false
	
	if dir != 0:
		dash_direction = sign(dir)
	else:
		dash_direction = -1.0 if animated_sprite_2d.flip_h else 1.0
		
	dash_timer.start()

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	if not is_on_floor():
		velocity.y = 0

func shoot():
	if bullet_node == null:
		return
	var bullet = bullet_node.instantiate()
	bullet.position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	get_tree().current_scene.call_deferred("add_child", bullet)
	
func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()
		
