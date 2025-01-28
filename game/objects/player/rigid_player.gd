extends RigidBody3D

@export_subgroup("Cheats")
@export var god_mode = false

@export_subgroup("Properties")
@export var movement_speed = 2600
@export var sv_airaccelerate_pct = 0.125
@export var jump_strength = 12
@export var movement_cap = 4.2
@export var coyote_time_s = 0.2

@export var bubble_time_s: int = 10
@export var bubble_min: float = 1
@export var bubble_min_plus_max: float = 1
@export var bubble_regen_factor: float = 10
@export var bubble_collider_name_starts_with: String = "rock"

@export var finish_collider_name_starts_with: String = "finish"
@export var death_collider_name_starts_with: String = "death"

@export var void_level: int = -10

@onready var model = $Model
@onready var bubble = $Model/Bubble

var on_ground = false
var on_finish = false
var air_time = 0
var current_bubble_time = bubble_time_s
var kill_player = false

var color_rect : ColorRect
var animation_player : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Wiiboard.boardJump.connect(jump)
	current_bubble_time = bubble_time_s

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.handle_controls(delta)
	self.handle_bubble(delta)
	
	var tree = get_tree()
	
	if position.y < void_level:
		kill_player = true

	if kill_player && !god_mode:
		tree.reload_current_scene()
		
	if on_finish:
		tree.change_scene_to_file("res://scenes/levels/level_" + str(tree.current_scene.name.get_slice(" ",1).to_int() + 1) + ".tscn")

func handle_bubble(delta: float) -> void:
	current_bubble_time -= delta
	var s = current_bubble_time/ bubble_time_s * bubble_min_plus_max + bubble_min
	$Model/Bubble/BubbleMesh.scale = Vector3(s, s, s)
	$Collider.scale = Vector3(s, s, s)
	
	if current_bubble_time < 0:
		kill_player = true

func handle_controls(delta: float):
	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	var input_force = input * movement_speed * delta * (1.0 if on_ground else sv_airaccelerate_pct)
	var predicted_vel = self.linear_velocity + input_force.normalized() * 0.01
	var vel = linear_velocity.length()
	var pred_vel = predicted_vel.length()
	# Only apply input if speed is either below cap OR input would not accelerate further
	if not (vel > movement_cap and pred_vel > vel):
		self.apply_central_force(input_force)
	
	if on_ground:
		air_time = 0
	else:
		air_time = air_time + delta
	
	# Jumping
	if Input.is_action_just_pressed("jump"):
		#if jump_single or jump_double:
			jump()
	
	if Input.is_action_just_pressed("godmode"):
		god_mode = !god_mode
		print("Godmode is now " + str(god_mode))
	
	if Input.is_action_just_pressed("next_level"):
		on_finish = true
	
	self.handle_animations(delta)

func handle_animations(delta):
	# Slowly revert to normal after squishy-squoshy
	bubble.scale = lerp(bubble.scale, Vector3.ONE, delta * 5)
	
	# Look in movement dir
	var horizontal_velocity = Vector2(linear_velocity.x, linear_velocity.z)
	var horizontal_vel_len = horizontal_velocity.length()
	if horizontal_vel_len > 1e-2:
		var current_angle = model.rotation.y
		var target_angle = -0.5*PI - horizontal_velocity.angle()
		if abs(current_angle - target_angle) > PI:
			if target_angle > 0:
				current_angle += 2*PI
			else:
				current_angle -= 2*PI
		model.rotation.y = lerp(current_angle, target_angle, delta * 5)
		if model.rotation.y > PI:
			model.rotation.y -= 2*PI
		elif model.rotation.y < -PI:
			model.rotation.y += 2*PI
	
	# Walking Animation
	var animation: AnimationPlayer = $Model/DuckAnimated/AnimationPlayer
	var speed_factor = horizontal_vel_len / movement_speed / delta
	if speed_factor > 0.01:
		if animation.current_animation != "AnimDuck_005":
			animation.play("AnimDuck_005", 0.1)
		animation.speed_scale = speed_factor * 100

	elif animation.current_animation != "AnimDuck_001":
		animation.play("AnimDuck_001", 0.1)

func jump():
	if air_time < coyote_time_s:
		var force = jump_strength * Vector3.UP
		var pred_force = self.linear_velocity + force
		if pred_force.y > jump_strength:
			force = max(0, (jump_strength - self.linear_velocity.y)) * Vector3.UP
		self.apply_central_impulse(force)
		air_time = coyote_time_s
		
		# Squish
		bubble.scale = Vector3(0.75, 1.2, 0.75)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var collision_count = state.get_contact_count()
	var maybe_on_ground = false
	var maybe_on_finish = false
	for idx in range(collision_count):
		#if state.get_contact_collider_object(idx).name.begins_with(bubble_collider_name_starts_with):
			#if current_bubble_time < bubble_time_s:
				#current_bubble_time += state.step * bubble_regen_factor
		if state.get_contact_collider_object(idx).name.begins_with(finish_collider_name_starts_with):
			maybe_on_finish = true
			pass
		if state.get_contact_collider_object(idx).name.begins_with(death_collider_name_starts_with):
			kill_player = true
		var col_normal = state.get_contact_local_normal(idx)
		var col_vel = abs(state.get_contact_local_velocity_at_position(idx).y)
		if col_normal.y > 0.5:
			col_vel /= 2
			if col_vel > 2 and not (on_ground or maybe_on_ground):
				bubble.scale = lerp(Vector3.ONE, Vector3(1.3, 0.6, 1.3), min(1, col_vel - 2))
			maybe_on_ground = true
	
	on_ground = maybe_on_ground
	on_finish = maybe_on_finish
	
func in_bubble(delta: float, is_evil: bool):
	if is_evil:
		current_bubble_time -= delta * bubble_regen_factor
	elif current_bubble_time < bubble_time_s:
		current_bubble_time += delta * bubble_regen_factor
