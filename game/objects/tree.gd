extends Node3D

@export var max_depth: int
@export var splits_min: int
@export var splits_max: int
@export var mesh: Mesh


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var meshInstance = addStick( Vector3(0,0,0), 0, 0,0)
	
	for depth in range(max_depth):
		pass
	
	add_child(meshInstance)
		
func recursiveAddSticks(prevDepth:int, prevMesh: Mesh):
	for depth in range(max_depth-prevDepth):
		pass
		
func addStick(pos: Vector3, x_rotate: int, y_rotate: int, z_rotate:int):
	var node = Node3D.new()
	
	var meshInstance = CSGMesh3D.new()
	meshInstance.rotate_x(x_rotate)
	meshInstance.rotate_y(y_rotate)
	meshInstance.rotate_z(z_rotate)
	meshInstance.position = pos
	meshInstance.mesh = mesh
	meshInstance.use_collision = true 
	node.add_child(meshInstance)
	return meshInstance
	
