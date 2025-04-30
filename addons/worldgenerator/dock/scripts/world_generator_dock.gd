@tool
class_name WorldGeneratorDock
extends Control

enum PreviewMode { WATER_LEVEL, HEAT_MAP, MOISTURE_MAP }

signal water_percent_changed(node: WorldGenerator, new_value: int)
signal world_wrap_changed(node: WorldGenerator, new_value: bool)
signal cold_poles_changed(node: WorldGenerator, new_value: bool)
signal heat_weights_changed(node: WorldGenerator, cold: int, mild: int, hot: int)
signal moisture_weights_changed(node: WorldGenerator, arid: int, temperate: int, humid: int)

# Scene Nodes
var label: Label
var primary_column: VBoxContainer
var preview: TextureRect
var preview_options: HBoxContainer
var water_level: WaterLevel
var heat_map: HeatMap
var moisture_map: MoistureMap
# Internal
var preview_mode: PreviewMode = PreviewMode.WATER_LEVEL
var target: WorldGenerator = null
var children_added: bool = false
var members_created: bool = false


func _init():
	self._create_members()
	self._connect_internal_signals()
	self._add_child_nodes()
	print(&"WorldGeneratorDock Initialized")


func clean_up():
	self._disconnect_internal_signals()
	self._remove_child_nodes()
	self._free_members()
	print(&"WorldGeneratorDock Cleaned Up")


func on_node_selected(node: Node):
	if node is WorldGenerator:
		print(&"WorldGenerator Detected")
		self._set_label_text(&"WorldGenerator Editor")
		self.target = node
		self._update_preview()
		self._connect_target()
		self.primary_column.visible = true
	else:
		self._set_label_text(&"Select a WorldGenerator Node to use this Dock")
		self._disconnect_target()
		self.target = null
		self.primary_column.hide()
		print(&"Not WorldGenerator")
	self.queue_redraw()


func _on_target_state_changed():
	if self.target == null:
		print(&"Target is null?!")
		return
	self._update_preview()


func _connect_target():
	if self.target != null:
		if not self.target.editor_state_changed.is_connected(self._on_target_state_changed):
			self.target.editor_state_changed.connect(self._on_target_state_changed)


func _disconnect_target():
	if self.target != null:
		if self.target.editor_state_changed.is_connected(self._on_target_state_changed):
			self.target.editor_state_changed.disconnect(self._on_target_state_changed)


func _update_preview():
	if self.target == null:
		self._set_label_text("WorldGenerator is missing!?")
	self._copy_from_world_generator(self.target)
	self._update_preview_gradient()
	self._update_preview_noise()
	self.queue_redraw()


func _update_preview_gradient():
	match self.preview_mode:
		PreviewMode.WATER_LEVEL:
			self.preview.texture.color_ramp = self.water_level.get_gradient()
			# print("water level gradient chosen with size %d" % self.gradient.offsets.size())
		PreviewMode.HEAT_MAP:
			self.preview.texture.color_ramp = self.heat_map.get_gradient()
			# print("heat map gradient chosen with size %d" % self.preview.texture.color_ramp.offsets.size())
		PreviewMode.MOISTURE_MAP:
			self.preview.texture.color_ramp = self.moisture_map.get_gradient()


func _update_preview_noise():
	match self.preview_mode:
		PreviewMode.WATER_LEVEL:
			self.preview.texture.noise = self.target.height_noise
		PreviewMode.HEAT_MAP:
			self.preview.texture.noise = self.target.heat_noise
		PreviewMode.MOISTURE_MAP:
			self.preview.texture.noise = self.target.moisture_noise


func _update_target():
	if self.target == null:
		print(&"Failed to update target: null")
		return



func _copy_from_world_generator(node: WorldGenerator):
	self.preview.texture.width = 2 ** node.width
	self.preview.texture.height = 2 ** node.height
	self.preview.texture.seamless = node.world_wrap


func _set_preview_water_level():
	self.preview_mode = PreviewMode.WATER_LEVEL
	self._update_preview()


func _set_preview_heat_map():
	self.preview_mode = PreviewMode.HEAT_MAP
	self._update_preview()


func _set_preview_moisture_map():
	self.preview_mode = PreviewMode.MOISTURE_MAP
	self._update_preview()


func _set_label_text(new_label: String):
	self.label.text = new_label
	self.label.queue_redraw()


## Creates the internal nodes and member instances for this node
func _create_members():
	if self.members_created:
		return
	# Scene Node Members
	self.label = Label.new()
	self.label.name = &"Label"
	self.label.text = &"Select a WorldGenerator Node to use this Dock"
	self.primary_column = VBoxContainer.new()
	self.primary_column.name = &"PrimaryColumn"
	self.preview = TextureRect.new()
	self.preview.name = &"Preview"
	self.preview_options = HBoxContainer.new()
	self.preview_options.name = &"PreviewOptions"
	self.water_level = WaterLevel.new()
	self.water_level.name = &"WaterLevel"
	self.heat_map = HeatMap.new()
	self.heat_map.name = &"HeatMap"
	self.moisture_map = MoistureMap.new()
	self.moisture_map.name = &"MoistureMap"
	# Internal Member Initialization
	self.preview.texture = NoiseTexture2D.new()
	self.preview.texture.noise = FastNoiseLite.new()
	self.preview.texture.color_ramp = self.water_level.get_gradient()
	# Finish
	self.members_created = true


## Adds appropriate child nodes to this node
func _add_child_nodes():
	if self.children_added:
		return
	self.preview_options.add_child(self.water_level)
	self.preview_options.add_child(self.heat_map)
	self.preview_options.add_child(self.moisture_map)
	self.primary_column.add_child(self.preview)
	self.primary_column.add_child(self.preview_options)
	self.add_child(self.label)
	self.add_child(self.primary_column)
	self.children_added = true


## Remove appropriate child nodes from this node
func _remove_child_nodes():
	if not self.children_added:
		return
	self.preview_options.remove_child.call_deferred(self.water_level)
	self.preview_options.remove_child.call_deferred(self.heat_map)
	self.preview_options.remove_child.call_deferred(self.moisture_map)
	self.primary_column.remove_child.call_deferred(self.preview)
	self.primary_column.remove_child.call_deferred(self.preview_options)
	self.remove_child.call_deferred(self.label)
	self.remove_child.call_deferred(self.primary_column)
	self.children_added = false


## Frees the members of this node
func _free_members():
	# Don't free if members not initialized
	if not self.members_created:
		return
	# Don't free if members still in scene tree
	if self.children_added:
		return
	self.water_level.queue_free()
	self.heat_map.queue_free()
	self.moisture_map.queue_free()
	self.preview.queue_free()
	self.preview_options.queue_free()
	self.label.queue_free()
	self.primary_column.queue_free()
	self.members_created = false


## Connects the internal signals for this node
func _connect_internal_signals():
	if not self.water_level.request_view.is_connected(self._set_preview_water_level):
		self.water_level.request_view.connect(self._set_preview_water_level)
	if not self.water_level.gradient_changed.is_connected(self._update_preview_gradient):
		self.water_level.gradient_changed.connect(self._update_preview_gradient)
	if not self.heat_map.request_view.is_connected(self._set_preview_heat_map):
		self.heat_map.request_view.connect(self._set_preview_heat_map)
	if not self.heat_map.gradient_changed.is_connected(self._update_preview_gradient):
		self.heat_map.gradient_changed.connect(self._update_preview_gradient)
	if not self.moisture_map.request_view.is_connected(self._set_preview_heat_map):
		self.moisture_map.request_view.connect(self._set_preview_heat_map)
	if not self.moisture_map.gradient_changed.is_connected(self._update_preview_gradient):
		self.moisture_map.gradient_changed.connect(self._update_preview_gradient)
	self._connect_target()


## Disconnects the internal signals for this node
func _disconnect_internal_signals():
	if self.water_level.request_view.is_connected(self._set_preview_water_level):
		self.water_level.request_view.disconnect(self._set_preview_water_level)
	if self.water_level.gradient_changed.is_connected(self._update_preview_gradient):
		self.water_level.gradient_changed.disconnect(self._update_preview_gradient)
	if self.heat_map.request_view.is_connected(self._set_preview_heat_map):
		self.heat_map.request_view.disconnect(self._set_preview_heat_map)
	if self.heat_map.gradient_changed.is_connected(self._update_preview_gradient):
		self.heat_map.gradient_changed.disconnect(self._update_preview_gradient)
	if self.moisture_map.request_view.is_connected(self._set_preview_heat_map):
		self.moisture_map.request_view.disconnect(self._set_preview_heat_map)
	if self.moisture_map.gradient_changed.is_connected(self._update_preview_gradient):
		self.moisture_map.gradient_changed.disconnect(self._update_preview_gradient)
	self._disconnect_target()
