@tool
extends EditorPlugin

# Plugin paths
const PLUGIN = "worldgenerator"
const PLUGIN_EDITOR = "editor"
const PLUGIN_CORE = "core"


func _enter_tree():
	print("Enable")
	if not EditorInterface.is_plugin_enabled(PLUGIN + "/" + PLUGIN_EDITOR):
		print("Enabling editor")
		EditorInterface.set_plugin_enabled(PLUGIN + "/" + PLUGIN_EDITOR, true)
	if not EditorInterface.is_plugin_enabled(PLUGIN + "/" + PLUGIN_CORE):
		print("Enabling core")
		EditorInterface.set_plugin_enabled(PLUGIN + "/" + PLUGIN_CORE, true)


func _exit_tree():
	print("Disable")
	if EditorInterface.is_plugin_enabled(PLUGIN + "/" + PLUGIN_EDITOR):
		print("Disabling editor")
		EditorInterface.set_plugin_enabled(PLUGIN + "/" + PLUGIN_EDITOR, false)
	if EditorInterface.is_plugin_enabled(PLUGIN + "/" + PLUGIN_CORE):
		print("Disabling core")
		EditorInterface.set_plugin_enabled(PLUGIN + "/" + PLUGIN_CORE, false)
