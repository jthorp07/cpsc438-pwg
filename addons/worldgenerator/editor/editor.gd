@tool
extends EditorPlugin

var dock: WorldGeneratorDock
var editor_selection: EditorSelection

func _enter_tree():
	print(&"Editor: Initialize Dock")
	dock = WorldGeneratorDock.new()
	print(&"Editor: Connect Selection Signal")
	editor_selection = EditorInterface.get_selection()
	if not editor_selection.selection_changed.is_connected(self._on_selection_changed):
		editor_selection.selection_changed.connect(self._on_selection_changed)
	print(&"Editor: Add Dock to Editor")
	add_control_to_bottom_panel(dock, "WorldGenerator")


func _exit_tree():
	print(&"Editor: Clean Up Dock")
	dock.clean_up()
	print(&"Editor: Disconnect Selection Signal")
	if editor_selection.selection_changed.is_connected(self._on_selection_changed):
		editor_selection.selection_changed.disconnect(self._on_selection_changed)
	print(&"Editor: Remove Dock from Editor")
	remove_control_from_bottom_panel.call_deferred(dock)
	print(&"Editor: Free Dock")
	dock.queue_free()


func _on_selection_changed():
	var selected := editor_selection.get_selected_nodes()
	if not selected.is_empty():
		var selected_node := selected[0]
		dock.on_node_selected(selected_node)
