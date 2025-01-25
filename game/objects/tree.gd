extends Node3D

@export var mesh: Mesh
@export var max_depth: int
@export var splits_min: int
@export var splits_max: int
@export var sub_scale_vector: Vector3
@export var rand_branch_y_offset_min: float = -0.2 
@export var rand_branch_y_offset_max: float = 0.2 
@export var branch_length: float = 6.8 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = Node3D.new()
	add_child(root)
	var stick = addStick(Vector3(0, 0, 0), Vector3(1, 1, 1), Vector3(0, 0, 0))  # Starting stick (root)
	root.add_child(stick)  # Add the root stick to the root node
	recursiveAddSticks(max_depth, stick)
	

func recursiveAddSticks(limit: int, prevMesh: Node3D) -> void:
	if limit <= 0:
		return
	
	var rand = randi_range(splits_min, splits_max)
	for i in range(rand):
		var rand_rotation = Vector3(randf_range(-90, 90), randf_range(0, 360), randf_range(-90, 90))
		var new_stick = addStick(rand_rotation, sub_scale_vector, Vector3(0, branch_length, 0))
		
		prevMesh.get_child(0).add_child(new_stick)  
		recursiveAddSticks(limit - 1, new_stick)

	
func addStick(rotation: Vector3, scale_vector: Vector3, position_offset: Vector3) -> Node3D:
	var node = Node3D.new()
	node.scale = scale_vector
	node.rotation_degrees = rotation
	node.auto_translate_mode = node.AUTO_TRANSLATE_MODE_INHERIT
	node.position = Vector3(0,randf_range(rand_branch_y_offset_min, rand_branch_y_offset_max), 0)
	var meshInstance = CSGMesh3D.new()
	meshInstance.position = position_offset
	meshInstance.mesh = mesh
	meshInstance.use_collision = true
	meshInstance.auto_translate_mode = node.AUTO_TRANSLATE_MODE_INHERIT
	node.add_child(meshInstance)
	return node
