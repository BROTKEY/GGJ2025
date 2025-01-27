@tool
extends EditorScenePostImportPlugin

func _post_process(scene) -> void:
	if get_option_value('glb_export_mesh'):
		print('[GlbImportFix] Processing scene "%s"' % scene.name)
		var meshes = []
		for child in scene.get_children():
			if child is MeshInstance3D:
				meshes.append(child.mesh)
		if len(meshes) == 1:
			print('[GlbImportFix] Scene "%s" has exactly one mesh, applying fixes' % scene.name)
			var mesh = meshes[0]
			save_mesh(mesh, scene.name)
		else:
			print('[GlbImportFix] Scene "%s" has %s meshes, skipping fixes' % [scene.name, len(meshes)])


func _get_import_options(path: String) -> void:
	if path.get_extension().to_lower() == 'glb':
		add_import_option('glb_export_mesh', true)
	else:
		add_import_option('glb_export_mesh', false)


func save_mesh(mesh, name):
	var pth = 'res://assets/meshes/' + name + '.res'
	print('[GlbImportFix] Saving mesh to %s' % pth)
	ResourceSaver.save(mesh, pth)
