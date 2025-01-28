extends Node

@export var sensitivity: float = 5.0
@export var max_force = 10.0

var jump_threshold: float = 25.0
var jump_timeout: float = 0.1
var last_jump: float = 0.0

@onready var player = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var g = Input.get_gravity()
	if g == null or g.length() < 1e-2:
		# No gravity sensor, don't use gyro controls
		return
	
	# Apply movement force
	var F = Vector3(g.x, 0.0, -g.y) * sensitivity;
	if F.length() > max_force:
		F = F.normalized() * max_force
	player.apply_central_force(F)
	
	# Jump
	var a = Input.get_accelerometer().length()
	if a > jump_threshold:
		if last_jump + (jump_timeout*1e3) < Time.get_ticks_msec():
			last_jump = Time.get_ticks_msec()
			player.jump()
