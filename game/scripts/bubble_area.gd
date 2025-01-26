extends Area3D

@export var is_evil: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.name == 'RigidPlayer':
			body.in_bubble(delta, self.is_evil)
		
