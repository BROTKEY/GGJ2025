extends Node3D

@export_range(0.0, 1.0, 0.01)
var intensity: float = 0.1
@export var movement_speed: float = 1.0
@export var decay_speed: float = 1.0
@export var radius: float = 1.0
@export var max_height: float = 2.0

var bubble_scene = preload("res://objects/EvilBubble.tscn")

var bubbles: Array
var time_since_last_spawn: float
var next_spawn_time: float
var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Collider.shape.height = height
	self.bubbles = Array()
	self.next_spawn_time = Time.get_ticks_msec()
	self.rng = RandomNumberGenerator.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.process_bubble_spawner()
	self.process_bubbles(delta)

func process_bubble_spawner():
	if self.rng.randf() < self.intensity:
		self.spawn_bubble()
	#while Time.get_ticks_msec() >= self.next_spawn_time:
		#self.spawn_bubble()
		#self.next_spawn_time += 1e-3 * max(0.0, self.rng.randfn(self.bubble_delay, self.bubble_delay_stdev))

func spawn_bubble():
	var bubble = bubble_scene.instantiate()
	bubble.movement_speed = self.movement_speed
	bubble.decay_speed = self.decay_speed
	bubble.max_height = self.max_height
	# Random position (will automatically be more dense in center)
	var angle = self.rng.randf() * 2.0 * PI
	var r = self.rng.randf() * self.radius
	var pos = Vector3(sin(angle), self.max_height, cos(angle)) * r
	bubble.position = pos
	$Model/Bubbles.add_child(bubble)
	bubble.owner = self

func process_bubbles(delta: float):
	var to_remove = Array()
	for bubble in $Model/Bubbles.get_children():
		if bubble.position.y < 0.0:
			to_remove.append(bubble)
	for bubble in to_remove:
		$Model/Bubbles.remove_child(bubble)
		bubble.queue_free()
