extends Node3D

@onready var path : Path3D  = $"."
@export var stone : Mesh 
@export var number_of_meshes : int  # Number of meshes to place
@export var x_rand_factor : int  # Number of meshes to place
@export var y_rand_factor : int  # Number of meshes to place
@export var z_rand_factor : int  # Number of meshes to place

func _ready():
	# Access the path's curve
	var curve = path.curve
	var total_length = 0.0
	var segment_lengths = []

	# Calculate the total length of the path and the lengths of each segment
	var point_count = curve.get_point_count()
	for i in range(1, point_count):
		var start_point = curve.get_point_position(i - 1)
		var end_point = curve.get_point_position(i)
		place_assets_along_path(start_point, end_point, number_of_meshes, i!=1)
		
func place_assets_along_path(start_point: Vector3, end_point: Vector3, count: int, deleteFirst: bool):
	var distance = start_point.distance_to(end_point)
	var interval = distance / (count - 1)
	for i in range(count):
		if i == 0 && deleteFirst:
			continue
		var t = i / float(count - 1)
		var position = start_point.lerp(end_point, t)
		var mesh_instance = CSGMesh3D.new()
		mesh_instance.mesh = stone
		var rand = randf()
		position.y += rand * y_rand_factor
		position.x += rand * x_rand_factor
		position.z += rand * z_rand_factor
		mesh_instance.position = position
		mesh_instance.rotate_x(360 * rand)
		mesh_instance.rotate_y(360 * rand)
		mesh_instance.rotate_z(360 * rand)
		mesh_instance.use_collision = true

		add_child(mesh_instance)
