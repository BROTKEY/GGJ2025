extends Node3D

@export var decay_speed: float = 1.0
@export var movement_speed: float = 1.0

#var spawn_time: float
var size: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.spawn_time = Time.get_ticks_msec()
	#$Mesh.material_override = $
	$Mesh.set_instance_shader_parameter('noise_offset', randf() * 10.0)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.y += movement_speed * delta;
	#self.size /= 1.0 + (delta * decay_speed)
	self.size = max(0.0, self.size - delta * decay_speed)
	$Mesh.set_instance_shader_parameter('size', self.size)
	
	#s.param
	pass
