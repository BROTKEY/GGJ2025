extends Node3D

@onready var stone : Mesh  = $pathtile.mesh
@onready var path : Path3D  = $"."
@export var number_of_meshes : int = 10  # Number of meshes to place

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
		place_assets_along_path(start_point, end_point, 4, i!=1)
		
func place_assets_along_path(start_point: Vector3, end_point: Vector3, count: int, deleteFirst: bool):
	var distance = start_point.distance_to(end_point)
	var interval = distance / (count - 1)
	for i in range(count):
		if i == 0 && deleteFirst:
			continue
		var t = i / float(count - 1)
		var position = start_point.lerp(end_point, t)
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = stone
		var rand = randf()
		position.y += rand * 0.15
		mesh_instance.position = position
		mesh_instance.rotate_y(rand * 360)

		add_child(mesh_instance)
