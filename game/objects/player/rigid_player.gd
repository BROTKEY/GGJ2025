extends RigidBody3D


@export_subgroup("Properties")
@export var movement_speed = 2500
@export var jump_strength = 700
@export var movement_cap = 5

@onready var model = $Model
@onready var view = $View

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.handle_controls(delta)


func handle_controls(delta: float):
	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	var input_force = input.rotated(Vector3.UP, view.rotation.y) * movement_speed * delta
	var predicted_vel = self.linear_velocity + input_force
	var vel = linear_velocity.length()
	print(vel)
	var pred_vel = predicted_vel.length()
	# Only apply input if speed is either below cap OR input would not accelerate further
	if not (vel > movement_cap and pred_vel > vel):
		self.apply_central_force(input_force)
	
	# Jumping
	if Input.is_action_just_pressed("jump"):
		#if jump_single or jump_double:
			jump()

func jump():
	# TODO: check if on ground
	var force = jump_strength * Vector3.UP
	self.apply_central_force(force)

	# TODO: fancy bouncy squishy bubble
	#model.scale = Vector3(0.75, 1.25, 0.75)
#
	#if jump_single:
		#jump_single = false;
		#jump_double = true;
	#else:
		#jump_double = false;
