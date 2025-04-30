@tool
extends EditorPlugin

const WATER_PERCENTAGE_PROPERTY := &"water_percentage"
const WORLD_WRAP_PROPERTY := &"world_wrap"
const COLD_POLES_PROPERTY := &"cold_poles"
const COLD_WEIGHT_PROPERTY := &"cold"
const MILD_WEIGHT_PROPERTY := &"mild"
const HOT_WEIGHT_PROPERTY := &"hot"
const ARID_WEIGHT_PROPERTY := &"arid"
const TEMPERATE_WEIGHT_PROPERTY := &"temperate"
const HUMID_WEIGHT_PROPERTY := &"humid"

var dock: WorldGeneratorDock
var editor_selection: EditorSelection

func _enter_tree():
	dock = WorldGeneratorDock.new()
	editor_selection = EditorInterface.get_selection()
	if not editor_selection.selection_changed.is_connected(self._on_selection_changed):
		editor_selection.selection_changed.connect(self._on_selection_changed)
	add_control_to_bottom_panel(dock, &"World Generator Editor")


func _exit_tree():
	pass


func _disable_plugin():
	dock.clean_up()
	if editor_selection.selection_changed.is_connected(self._on_selection_changed):
		editor_selection.selection_changed.disconnect(self._on_selection_changed)
	remove_control_from_bottom_panel(dock)
	dock.queue_free()
	dock = null


func _on_selection_changed():
	var selected := editor_selection.get_selected_nodes()
	if not selected.is_empty():
		var selected_node := selected[0]
		dock.on_node_selected(selected_node)


func update_water_percentage(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Water Percentage")
	get_undo_redo().add_do_property(node, WATER_PERCENTAGE_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, WATER_PERCENTAGE_PROPERTY, node.water_percentage)
	get_undo_redo().commit_action()


func update_world_wrap(node: WorldGenerator, new_value: bool):
	get_undo_redo().create_action(&"Change World Wrap")
	get_undo_redo().add_do_property(node, WORLD_WRAP_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, WORLD_WRAP_PROPERTY, node.world_wrap)
	get_undo_redo().commit_action()


func update_cold_poles(node: WorldGenerator, new_value: bool):
	get_undo_redo().create_action(&"Change Cold Poles")
	get_undo_redo().add_do_property(node, COLD_POLES_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, COLD_POLES_PROPERTY, node.cold_poles)
	get_undo_redo().commit_action()


func update_cold_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Cold Weight")
	get_undo_redo().add_do_property(node, COLD_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, COLD_WEIGHT_PROPERTY, node.cold)
	get_undo_redo().commit_action()


func update_mild_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Mild Weight")
	get_undo_redo().add_do_property(node, MILD_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, MILD_WEIGHT_PROPERTY, node.mild)
	get_undo_redo().commit_action()


func update_hot_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Hot Weight")
	get_undo_redo().add_do_property(node, HOT_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, HOT_WEIGHT_PROPERTY, node.hot)
	get_undo_redo().commit_action()


func update_arid_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Arid Weight")
	get_undo_redo().add_do_property(node, ARID_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, ARID_WEIGHT_PROPERTY, node.arid)
	get_undo_redo().commit_action()


func update_temperate_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Temperate Weight")
	get_undo_redo().add_do_property(node, TEMPERATE_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, TEMPERATE_WEIGHT_PROPERTY, node.temperate)
	get_undo_redo().commit_action()


func update_humid_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Humid Weight")
	get_undo_redo().add_do_property(node, HUMID_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, HUMID_WEIGHT_PROPERTY, node.humid)
	get_undo_redo().commit_action()
