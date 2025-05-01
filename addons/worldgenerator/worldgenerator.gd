@tool
extends EditorPlugin

# Subplugin paths
const PLUGIN_DOCK = &"worldgenerator/dock"
const PLUGIN_CORE = &"worldgenerator/core"


func _enter_tree():
	if not EditorInterface.is_plugin_enabled(PLUGIN_DOCK):
		EditorInterface.set_plugin_enabled(PLUGIN_DOCK, true)
	if not EditorInterface.is_plugin_enabled(PLUGIN_CORE):
		EditorInterface.set_plugin_enabled(PLUGIN_CORE, true)


func _disable_plugin():
	if EditorInterface.is_plugin_enabled(PLUGIN_DOCK):
		EditorInterface.set_plugin_enabled(PLUGIN_DOCK, false)
	if EditorInterface.is_plugin_enabled(PLUGIN_CORE):
		EditorInterface.set_plugin_enabled(PLUGIN_CORE, false)
