extends Node3D

@export var decay_speed: float = 1.0
@export var movement_speed: float = 1.0
@export var max_height: float

#var spawn_time: float
var size: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.spawn_time = Time.get_ticks_msec()
	$Mesh.set_instance_shader_parameter('noise_offset', randf() * 10.0)
	$Mesh.set_instance_shader_parameter('color_override', Vector3(1.0, 0.0, 0.0))
	$Mesh.set_instance_shader_parameter('color_override_strength', 0.9)
	self.position.y = max_height

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.y -= movement_speed * delta;
	#self.size /= 1.0 + (delta * decay_speed)
	self.size = (self.position.y / self.max_height) * 0.8 + 0.2
	$Mesh.set_instance_shader_parameter('size', self.size)
	
	#s.param
	pass
