@tool
extends EditorScenePostImportPlugin

var pixpal_material: ShaderMaterial

func _pre_process(scene: Node) -> void:
	# Ensure the output directory exists
	var output_dir = DirAccess.open("res://assets/meshes")
	if output_dir == null:
		DirAccess.make_dir_recursive_absolute("res://assets/meshes")
	
	# Start processing the scene
	iterate(scene)

# Loops through each imported Node looking for PixPal materials to replace and exports meshes.
func iterate(node: Node) -> void:
	# We only care about MeshInstances
	if node is ImporterMeshInstance3D:
		#var mesh: ImporterMesh = node.mesh
		var mesh: Mesh = node.mesh.get_mesh()
		if mesh:
			var mesh_resource_path = "res://assets/meshes/%s.%s" % [node.name, "mesh"]

			# Try exporting the mesh resource
			var save_result = ResourceSaver.save(mesh, mesh_resource_path)
			if save_result != OK:
				push_error("Failed to save mesh: %s (Error code: %d)" % [mesh_resource_path, save_result])
			else:
				print("Mesh saved to: ", mesh_resource_path)

			# Loop through mesh materials looking for a PixPal
			for index in range(mesh.get_surface_count()):
				var material = mesh.get_surface_material(index)
				if material and material.resource_name.ends_with('PixPal'):
					mesh.set_surface_material(index, get_pixpal_material())

	# Recursively process child nodes
	for child in node.get_children():
		iterate(child)

# Returns the PixPal ShaderMaterial. Caches for faster retrieval.
func get_pixpal_material() -> ShaderMaterial:
	if not pixpal_material:
		pixpal_material = load("res://addons/pixpal_tools/Imphenzia/PixPal/Materials/M_ImphenziaPixPal.tres")

	return pixpal_material
