@tool
class_name HeatMap
extends VBoxContainer

const BLUE: Color = Color(0.0, 0.0, 1.0)
const GREEN: Color = Color(0.0, 1.0, 0.0)
const PURPLE: Color = Color(0.25, 0.0, 0.75)
const YELLOW: Color = Color(0.8, 0.8, 0.0)
const RED: Color = Color(1.0, 0.0, 0.0)

signal request_view
signal gradient_changed

# Scene Nodes
var label: Label
var inputs_row: HBoxContainer
var blue_in: SliderOption
var green_in: SliderOption
var yellow_in: SliderOption
var view_button: Button
# Internal
var gradient: Gradient
var children_added: bool = false
var members_created: bool = false

func _init():
	self._create_members()
	self._add_child_nodes()
	self._make_gradient()
	self._connect_internal_signals()
	print(&"HeatMap Initialized")


func clean_up():
	self._disconnect_internal_signals()
	self._remove_child_nodes()
	self._free_members()
	print(&"HeatMap Cleaned Up")


func get_gradient() -> Gradient:
	return self.gradient

## Make gradient for heat map preview
func _make_gradient():
	var colors: PackedColorArray = [
		PURPLE,
		BLUE,
		GREEN,
		YELLOW,
		RED
	]
	var cutoffs: PackedFloat32Array = [
		0.0,
		self.blue_in.get_value(),
		self.green_in.get_value(),
		self.yellow_in.get_value(),
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
	self.blue_in = SliderOption.new(&"Blue", 0.2)
	self.blue_in.name = &"Blue"
	self.green_in = SliderOption.new(&"Green", 0.4)
	self.green_in.name = &"Green"
	self.yellow_in = SliderOption.new(&"Yellow", 0.6)
	self.yellow_in.name = &"Yellow"
	self.view_button = Button.new()
	self.view_button.text = &"Show View"
	self.view_button.name = &"ViewButton"
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
	self.inputs_row.add_child(self.blue_in)
	self.inputs_row.add_child(self.green_in)
	self.inputs_row.add_child(self.yellow_in)
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
	self.blue_in.clean_up()
	self.inputs_row.remove_child.call_deferred(self.blue_in)
	self.green_in.clean_up()
	self.inputs_row.remove_child.call_deferred(self.green_in)
	self.yellow_in.clean_up()
	self.inputs_row.remove_child.call_deferred(self.yellow_in)
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
	self.blue_in.queue_free()
	self.green_in.queue_free()
	self.yellow_in.queue_free()
	self.view_button.queue_free()
	self.members_created = false
	# print(&"Members Freed")


## Connects the internal signals for this node
func _connect_internal_signals():
	if not self.view_button.pressed.is_connected(self.request_view.emit):
		self.view_button.pressed.connect(self.request_view.emit)
	if not self.blue_in.value_updated.is_connected(self._make_gradient):
		self.blue_in.value_updated.connect(self._make_gradient)
	if not self.green_in.value_updated.is_connected(self._make_gradient):
		self.green_in.value_updated.connect(self._make_gradient)
	if not self.yellow_in.value_updated.is_connected(self._make_gradient):
		self.yellow_in.value_updated.connect(self._make_gradient)


## Disconnects the internal signals for this node
func _disconnect_internal_signals():
	if self.view_button.pressed.is_connected(self.request_view.emit):
		self.view_button.pressed.connect(self.request_view.emit)
	if self.blue_in.value_updated.is_connected(self._make_gradient):
		self.blue_in.value_updated.disconnect(self._make_gradient)
	if self.green_in.value_updated.is_connected(self._make_gradient):
		self.green_in.value_updated.disconnect(self._make_gradient)
	if self.yellow_in.value_updated.is_connected(self._make_gradient):
		self.yellow_in.value_updated.disconnect(self._make_gradient)
