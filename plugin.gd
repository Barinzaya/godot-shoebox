tool
extends EditorPlugin

var import_plugin = null

func _enter_tree():
	if import_plugin == null:
		import_plugin = preload("import.gd").new()
		add_import_plugin(import_plugin)

func _exit_tree():
	if import_plugin != null:
		remove_import_plugin(import_plugin)
		import_plugin = null
