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
	self.dock = WorldGeneratorDock.new()
	self.editor_selection = EditorInterface.get_selection()
	if not self.editor_selection.selection_changed.is_connected(self._on_selection_changed):
		self.editor_selection.selection_changed.connect(self._on_selection_changed)
	self.connect_dock_signals()
	add_control_to_bottom_panel(self.dock, &"World Generator Editor")


func _exit_tree():
	pass


func _disable_plugin():
	self.disconnect_dock_signals()
	self.dock.clean_up()
	if self.editor_selection.selection_changed.is_connected(self._on_selection_changed):
		self.editor_selection.selection_changed.disconnect(self._on_selection_changed)
	remove_control_from_bottom_panel(self.dock)
	self.dock.queue_free()
	self.dock = null


func _on_selection_changed():
	var selected := self.editor_selection.get_selected_nodes()
	if not selected.is_empty():
		var selected_node := selected[0]
		self.dock.on_node_selected(selected_node)


func connect_dock_signals():
	if not self.dock.water_percent_changed.is_connected(self.update_water_percentage):
		self.dock.water_percent_changed.connect(self.update_water_percentage)
	if not self.dock.world_wrap_changed.is_connected(self.update_world_wrap):
		self.dock.world_wrap_changed.connect(self.update_world_wrap)
	if not self.dock.cold_poles_changed.is_connected(self.update_cold_poles):
		self.dock.cold_poles_changed.connect(self.update_cold_poles)
	if not self.dock.heat_weights_changed.is_connected(self.update_heat_weights):
		self.dock.heat_weights_changed.connect(self.update_heat_weights)
	if not self.dock.moisture_weights_changed.is_connected(self.update_moisture_weights):
		self.dock.moisture_weights_changed.connect(self.update_moisture_weights)


func disconnect_dock_signals():
	if self.dock.water_percent_changed.is_connected(self.update_water_percentage):
		self.dock.water_percent_changed.disconnect(self.update_water_percentage)
	if self.dock.world_wrap_changed.is_connected(self.update_world_wrap):
		self.dock.world_wrap_changed.disconnect(self.update_world_wrap)
	if self.dock.cold_poles_changed.is_connected(self.update_cold_poles):
		self.dock.cold_poles_changed.disconnect(self.update_cold_poles)
	if self.dock.heat_weights_changed.is_connected(self.update_heat_weights):
		self.dock.heat_weights_changed.disconnect(self.update_heat_weights)
	if self.dock.moisture_weights_changed.is_connected(self.update_moisture_weights):
		self.dock.moisture_weights_changed.disconnect(self.update_moisture_weights)


func update_heat_weights(node: WorldGenerator, cold: int, mild: int, hot: int):
	self._update_cold_weight(node, cold)
	self._update_mild_weight(node, mild)
	self._update_hot_weight(node, hot)


func update_moisture_weights(node: WorldGenerator, arid: int, temperate: int, humid: int):
	self._update_arid_weight(node, arid)
	self._update_temperate_weight(node, temperate)
	self._update_humid_weight(node, humid)


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


func _update_cold_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Cold Weight")
	get_undo_redo().add_do_property(node, COLD_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, COLD_WEIGHT_PROPERTY, node.cold)
	get_undo_redo().commit_action()


func _update_mild_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Mild Weight")
	get_undo_redo().add_do_property(node, MILD_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, MILD_WEIGHT_PROPERTY, node.mild)
	get_undo_redo().commit_action()


func _update_hot_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Hot Weight")
	get_undo_redo().add_do_property(node, HOT_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, HOT_WEIGHT_PROPERTY, node.hot)
	get_undo_redo().commit_action()


func _update_arid_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Arid Weight")
	get_undo_redo().add_do_property(node, ARID_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, ARID_WEIGHT_PROPERTY, node.arid)
	get_undo_redo().commit_action()


func _update_temperate_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Temperate Weight")
	get_undo_redo().add_do_property(node, TEMPERATE_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, TEMPERATE_WEIGHT_PROPERTY, node.temperate)
	get_undo_redo().commit_action()


func _update_humid_weight(node: WorldGenerator, new_value: int):
	get_undo_redo().create_action(&"Change Humid Weight")
	get_undo_redo().add_do_property(node, HUMID_WEIGHT_PROPERTY, new_value)
	get_undo_redo().add_undo_property(node, HUMID_WEIGHT_PROPERTY, node.humid)
	get_undo_redo().commit_action()
