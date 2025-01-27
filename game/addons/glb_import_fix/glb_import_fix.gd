@tool
extends EditorPlugin

var import_script := preload("importer.gd").new()

func _enter_tree() -> void:
	add_scene_post_import_plugin(import_script)


func _exit_tree() -> void:
	remove_scene_post_import_plugin(import_script)
