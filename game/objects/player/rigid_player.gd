extends RigidBody3D

@export_subgroup("Properties")
@export var movement_speed = 2600
@export var sv_airaccelerate_pct = 0.125
@export var jump_strength = 12
@export var movement_cap = 4.2
@export var coyote_time_s = 0.2

@onready var model = $Model

var on_ground = false
var air_time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Wiiboard.boardJump.connect(jump)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.handle_controls(delta)


func handle_controls(delta: float):
	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	var input_force = input * movement_speed * delta * (1 if on_ground else sv_airaccelerate_pct)
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

func jump():
	if air_time < coyote_time_s:
		var cur_yf = self.linear_velocity.y
		var force = jump_strength * Vector3.UP
		var pred_force = self.linear_velocity + force
		if pred_force.y > jump_strength:
			force = max(0, (jump_strength - self.linear_velocity.y)) * Vector3.UP
		self.apply_central_impulse(force)
		air_time = coyote_time_s
		print("Jump")

	# TODO: fancy bouncy squishy bubble
	#model.scale = Vector3(0.75, 1.25, 0.75)
#
	#if jump_single:
		#jump_single = false;
		#jump_double = true;
	#else:
		#jump_double = false;

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var collision_count = state.get_contact_count()
	var maybe_on_ground = false
	for id in range(collision_count):
		var col_normal = state.get_contact_local_normal(id)
		if col_normal.y > 0.5:
			maybe_on_ground = true
	
	on_ground = maybe_on_ground
