@tool
extends EditorScript

var wood: Mesh = load("res://assets/meshes/Plant_001.mesh")
var leaf: Mesh = load("res://assets/meshes/Leaf_001.mesh")
var max_depth: int = 2
var splits_min: int = 5
var splits_max: int = 9
var sub_scale_vector: Vector3 = Vector3(0.3, 0.5, 0.3)
var leaf_scale_vector: Vector3 = Vector3(3, 3, 3)
var rand_branch_y_offset_min: float = -1
var rand_branch_y_offset_max: float = 5
var branch_length: float = 6.9

var root: Node = null

# Called when the node enters the scene tree for the first time.
func _run() -> void:
	#var root = Node3D.new()
	#var scene = get_editor_interface().get_edited_scene_root()
	root = get_scene().get_tree().edited_scene_root
	var scene = get_scene().find_children("tree*")
	for child in scene:
		for n in child.get_children():
			if n.get_index() == 0:
				continue
			child.remove_child(n)
			n.queue_free() 
		#var childpack = child as PackedScene
		#print(childpack)
	#scene.add_child(root)
		var stick = addStick(Vector3(0, 0, 0), Vector3(1, 1, 1), child.get_child(0).position, false, true, false)  # Starting stick (root)
		child.add_child(stick)  # Add the root stick to the root node
		recursiveAddSticks(max_depth, stick)
		recursively_set_owner(child, get_scene().get_tree().edited_scene_root)
	EditorInterface.save_all_scenes()

func recursiveAddSticks(limit: int, prevMesh: Node3D) -> void:
	if limit <= 0:
		return
	
	var rand = randi_range(splits_min, splits_max)
	for i in range(rand):
		var x_change = randf_range(-60, 60)
		var z_change = randf_range(-60, 60)
		var y_change = 180 if z_change<0 else 0 + x_change
		var rand_rotation = Vector3(x_change, y_change, z_change)
		var new_stick = addStick(rand_rotation, sub_scale_vector, Vector3(0, branch_length, 0), true, false, true)
		
		prevMesh.get_child(0).add_child(new_stick)
		recursiveAddSticks(limit - 1, new_stick)

	
func addStick(rotation: Vector3, scale_vector: Vector3, position_offset: Vector3, spawn_leaf: bool, collision: bool, rand_alt:bool) -> Node3D:
	var node = Node3D.new()
	node.scale = scale_vector
	node.rotation_degrees = rotation
	node.auto_translate_mode = node.AUTO_TRANSLATE_MODE_INHERIT
	
	# Apply random Y offset if needed
	if rand_alt:
		node.position = Vector3(0, randf_range(rand_branch_y_offset_min, rand_branch_y_offset_max), 0)
	
	# Create the branch mesh
	var meshInstance = CSGMesh3D.new()
	meshInstance.position = position_offset
	meshInstance.mesh = wood
	meshInstance.use_collision = collision
	meshInstance.auto_translate_mode = node.AUTO_TRANSLATE_MODE_INHERIT
	
	# Create the leaf mesh and position it
	if spawn_leaf:
		var leafInstance = CSGMesh3D.new()
		leafInstance.mesh = leaf
		leafInstance.scale = leaf_scale_vector
		leafInstance.position = Vector3(0, branch_length, 0)
		leafInstance.material = load("res://addons/pixpal_tools/Imphenzia/PixPal/Materials/ImphenziaPixPal.tres")  # Place leaf at the end of the branch (you can adjust this position)
		
		# Add leaf as a child of the branch mesh
		meshInstance.add_child(leafInstance)
	
	node.add_child(meshInstance)
	return node

func recursively_set_owner(node: Node, root):
	for child in node.get_children():
		child.owner = root
		recursively_set_owner(child, root)
