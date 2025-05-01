@tool
class_name HeatMap
extends VBoxContainer

const BLUE: Color = Color(0.0, 0.0, 1.0)
const YELLOW: Color = Color(1.0, 1.0, 0.0)
const RED: Color = Color(1.0, 0.0, 0.0)

signal request_view
signal gradient_changed

# Scene Nodes
var label: Label
var inputs_row: HBoxContainer
var cold_in: SliderOption
var temperate_in: SliderOption
var hot_in: SliderOption
var view_button: Button
# Internal
var gradient: Gradient
var children_added: bool = false
var members_created: bool = false

func _init():
	self._create_members()
	self._add_child_nodes()
	self._connect_internal_signals()


func clean_up():
	self._disconnect_internal_signals()
	self._remove_child_nodes()
	self._free_members()


func get_weights() -> Vector3i:
	var weights := Vector3i(self.cold_in.get_value(), self.temperate_in.get_value(), self.hot_in.get_value())
	return weights


func get_gradient() -> Gradient:
	return self.gradient

## Make gradient for heat map preview
func _make_gradient(_ignored: float = 0.0):
	var colors: PackedColorArray = [
		BLUE,
		BLUE,
		YELLOW,
		YELLOW,
		RED,
		RED
	]
	var percentiles := WorldGeneratorUtils.percentiles_from_weights([
		self.cold_in.get_value(),
		self.temperate_in.get_value(),
		self.hot_in.get_value()
	])
	var cutoffs: PackedFloat32Array = [
		0.0,
		percentiles[0],
		percentiles[0],
		percentiles[1],
		percentiles[1],
		1.0
	]
	var grad = Gradient.new()
	grad.colors = colors
	grad.offsets = cutoffs
	self.gradient = grad
	self.gradient_changed.emit()


## Creates the internal nodes and member instances for this node
func _create_members():
	# Don't create if members already initialized
	if self.members_created:
		return
	self.label = Label.new()
	self.label.text = &"Heat Map"
	self.label.name = &"Label"
	self.inputs_row = HBoxContainer.new()
	self.inputs_row.name = &"Inputs"
	self.cold_in = SliderOption.new(&"Cold", 1)
	self.cold_in.name = &"Cold"
	self.temperate_in = SliderOption.new(&"Temperate", 1)
	self.temperate_in.name = &"Temperate"
	self.hot_in = SliderOption.new(&"Hot", 1)
	self.hot_in.name = &"Hot"
	self.view_button = Button.new()
	self.view_button.text = &"Show View"
	self.view_button.name = &"ViewButton"
	self._make_gradient()
	self.members_created = true
	# print(&"Members Created")


## Adds appropriate child nodes to this node
func _add_child_nodes():
	# Don't re-add if children already added
	if self.children_added:
		return
	# Don't add if members not initialized
	if not self.members_created:
		return
	add_child(self.label)
	self.inputs_row.add_child(self.cold_in)
	self.inputs_row.add_child(self.temperate_in)
	self.inputs_row.add_child(self.hot_in)
	add_child(self.inputs_row)
	add_child(self.view_button)
	self.children_added = true
	# print(&"Children Added")


## Remove appropriate child nodes from this node
func _remove_child_nodes():
	# Don't remove if no children to remove
	if not self.children_added:
		return
	# Don't remove if children not initialized
	if not self.members_created:
		return
	self.remove_child.call_deferred(self.label)
	self.cold_in.clean_up()
	self.inputs_row.remove_child.call_deferred(self.cold_in)
	self.temperate_in.clean_up()
	self.inputs_row.remove_child.call_deferred(self.temperate_in)
	self.hot_in.clean_up()
	self.inputs_row.remove_child.call_deferred(self.hot_in)
	self.remove_child.call_deferred(self.inputs_row)
	self.remove_child.call_deferred(self.view_button)
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
	self.label.queue_free()
	self.inputs_row.queue_free()
	self.cold_in.queue_free()
	self.temperate_in.queue_free()
	self.hot_in.queue_free()
	self.view_button.queue_free()
	self.members_created = false
	# print(&"Members Freed")


## Connects the internal signals for this node
func _connect_internal_signals():
	if not self.view_button.pressed.is_connected(self.request_view.emit):
		self.view_button.pressed.connect(self.request_view.emit)
	if not self.cold_in.value_updated.is_connected(self._make_gradient):
		self.cold_in.value_updated.connect(self._make_gradient)
	if not self.temperate_in.value_updated.is_connected(self._make_gradient):
		self.temperate_in.value_updated.connect(self._make_gradient)
	if not self.hot_in.value_updated.is_connected(self._make_gradient):
		self.hot_in.value_updated.connect(self._make_gradient)


## Disconnects the internal signals for this node
func _disconnect_internal_signals():
	if self.view_button.pressed.is_connected(self.request_view.emit):
		self.view_button.pressed.connect(self.request_view.emit)
	if self.cold_in.value_updated.is_connected(self._make_gradient):
		self.cold_in.value_updated.disconnect(self._make_gradient)
	if self.temperate_in.value_updated.is_connected(self._make_gradient):
		self.temperate_in.value_updated.disconnect(self._make_gradient)
	if self.hot_in.value_updated.is_connected(self._make_gradient):
		self.hot_in.value_updated.disconnect(self._make_gradient)
