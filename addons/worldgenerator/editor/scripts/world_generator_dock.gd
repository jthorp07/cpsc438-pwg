@tool
class_name WorldGeneratorDock
extends Control

enum PreviewMode { WATER_LEVEL, HEAT_MAP, MOISTURE_MAP }

# Scene Nodes
var label: Label
var primary_column: VBoxContainer
var preview: TextureRect
var preview_options: HBoxContainer
var water_level: WaterLevel
var heat_map: HeatMap
# Internal
var noise_texture: NoiseTexture2D
var noise: FastNoiseLite
var gradient: Gradient
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
		self._copy_from_world_generator(node as WorldGenerator)
		self.target = node
		self._connect_target()
	else:
		self._disconnect_target()
		self.target = null
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
	print(&"Update Preview")
	self._copy_from_world_generator(self.target)
	match self.preview_mode:
		PreviewMode.WATER_LEVEL:
			self.gradient = self.water_level.get_gradient()
		PreviewMode.HEAT_MAP:
			self.gradient = self.heat_map.get_gradient()
		PreviewMode.MOISTURE_MAP:
			# self.gradient = self.moisture_map.get_gradient()
			pass
	self.noise_texture.noise = self.noise
	self.noise_texture.color_ramp = self.gradient
	self.preview.texture = self.noise_texture
	self.queue_redraw()


func _copy_from_world_generator(node: WorldGenerator):
	self.noise_texture.width = 2 ** node.width
	self.noise_texture.height = 2 ** node.height
	match self.preview_mode:
		PreviewMode.WATER_LEVEL:
			self.noise = node.height_noise
		PreviewMode.HEAT_MAP:
			self.noise = node.heat_noise
		PreviewMode.MOISTURE_MAP:
			self.noise = node.moisture_noise


func _set_preview_water_level():
	self.preview_mode = PreviewMode.WATER_LEVEL


func _set_preview_heat_map():
	self.preview_mode = PreviewMode.HEAT_MAP


func _set_preview_moisture_map():
	self.preview_mode = PreviewMode.MOISTURE_MAP


## Creates the internal nodes and member instances for this node
func _create_members():
	if self.members_created:
		return
	# Scene Node Members
	self.label = Label.new()
	self.label.name = "Label"
	self.label.text = "Select a WorldGenerator Node to use this Dock"
	self.primary_column = VBoxContainer.new()
	self.primary_column.name = "PrimaryColumn"
	self.preview = TextureRect.new()
	self.preview.name = "Preview"
	self.preview_options = HBoxContainer.new()
	self.preview_options.name = "PreviewOptions"
	self.water_level = WaterLevel.new()
	self.water_level.name = "WaterLevel"
	self.heat_map = HeatMap.new()
	self.heat_map.name = "HeatMap"
	# TODO: Moisture Map Options
	# Internal Member Initialization
	self.noise_texture = NoiseTexture2D.new()
	self.noise = FastNoiseLite.new()
	self.gradient = self.water_level.get_gradient()
	self.noise_texture.noise = self.noise
	self.noise_texture.color_ramp = self.gradient
	self.preview.texture = self.noise_texture
	# Finish
	self.members_created = true
	# print(&"Members Created")


## Adds appropriate child nodes to this node
func _add_child_nodes():
	if self.children_added:
		return
	self.preview_options.add_child(self.water_level)
	self.preview_options.add_child(self.heat_map)
	# TODO: Moisture Map Options
	self.primary_column.add_child(self.preview)
	self.primary_column.add_child(self.preview_options)
	self.add_child(self.label)
	self.add_child(self.primary_column)
	self.children_added = true
	# print(&"Children Added")


## Remove appropriate child nodes from this node
func _remove_child_nodes():
	if not self.children_added:
		return
	self.preview_options.remove_child.call_deferred(self.water_level)
	self.preview_options.remove_child.call_deferred(self.heat_map)
	self.primary_column.remove_child.call_deferred(self.preview)
	self.primary_column.remove_child.call_deferred(self.preview_options)
	self.remove_child.call_deferred(self.label)
	self.remove_child.call_deferred(self.primary_column)
	self.children_added = false
	# print(&"Children Removed")


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
	self.preview.queue_free()
	self.preview_options.queue_free()
	self.label.queue_free()
	self.primary_column.queue_free()
	self.members_created = false
	# print(&"Members Freed")


## Connects the internal signals for this node
func _connect_internal_signals():
	if not self.water_level.request_view.is_connected(self._set_preview_water_level):
		self.water_level.request_view.connect(self._set_preview_water_level)
	if not self.heat_map.request_view.is_connected(self._set_preview_heat_map):
		self.heat_map.request_view.connect(self._set_preview_heat_map)
	self._connect_target()


## Disconnects the internal signals for this node
func _disconnect_internal_signals():
	if self.water_level.request_view.is_connected(self._set_preview_water_level):
		self.water_level.request_view.disconnect(self._set_preview_water_level)
	if self.heat_map.request_view.is_connected(self._set_preview_heat_map):
		self.heat_map.request_view.disconnect(self._set_preview_heat_map)
	self._disconnect_target()
