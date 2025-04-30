@tool
class_name WaterLevel
extends VBoxContainer

const BLUE := Color(0.0, 0.0, 1.0)
const GREEN := Color(0.0, 1.0, 0.0)
const INITIAL_WATER_LEVEL: int = 60

signal request_view
signal gradient_changed

# Scene Nodes
var label: Label
var slider: HSlider
var view_button: Button
# Internal
var gradient: Gradient
var members_created: bool = false
var children_added: bool = false

func _init():
	self.alignment = BoxContainer.ALIGNMENT_CENTER
	self._create_members()
	self._add_child_nodes()
	self._connect_internal_signals()


func clean_up():
	self._disconnect_internal_signals()
	self._remove_child_nodes()
	self._free_members()


func get_water_level() -> int:
	return self.slider.value


func get_gradient() -> Gradient:
	return self.gradient


## Update gradient and label text
func _on_slider_value_changed(value: int):
	self._make_gradient(float(value) * 0.01)
	self._update_label_text(value)


## Create the gradient for the water level
func _make_gradient(land_start: float):
	var colors: PackedColorArray = [ BLUE, BLUE, GREEN, GREEN ]
	var cutoffs: PackedFloat32Array = [0.0, land_start, land_start, 1.0]
	var grad = Gradient.new()
	grad.colors = colors
	grad.offsets = cutoffs
	self.gradient = grad
	self.gradient_changed.emit()


## Update the water level label with a new value
func _update_label_text(val: int):
	self.label.text = "Water Percentage: %3d%%" % val
	self.queue_redraw()


## Creates the internal nodes and member instances for this node
func _create_members():
	if self.members_created:
		return
	self.label = Label.new()
	self.label.name = &"Label"
	self._update_label_text(INITIAL_WATER_LEVEL)
	self._make_gradient(INITIAL_WATER_LEVEL)
	self.slider = HSlider.new()
	self.slider.name = &"Slider"
	self.slider.value = INITIAL_WATER_LEVEL
	self.slider.max_value = 100
	self.slider.min_value = 0
	self.slider.step = 1
	self.slider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	self.view_button = Button.new()
	self.view_button.text = &"Show View"
	self.members_created = true
	# print(&"Members Created")


## Adds appropriate child nodes to this node
func _add_child_nodes():
	if self.children_added:
		return
	self.add_child(self.label)
	self.add_child(self.slider)
	self.add_child(self.view_button)
	self.children_added = true


## Remove appropriate child nodes from this node
func _remove_child_nodes():
	if not self.children_added:
		return
	self.remove_child.call_deferred(self.label)
	self.remove_child.call_deferred(self.slider)
	self.remove_child.call_deferred(self.view_button)
	self.children_added = false


## Frees the members of this node
func _free_members():
	# Don't free if members not initialized
	if not self.members_created:
		return
	# Don't free if members still in scene tree
	if self.children_added:
		return
	self.label.queue_free()
	self.slider.queue_free()
	self.view_button.queue_free()
	self.members_created = false


## Connects the internal signals for this node
func _connect_internal_signals():
	if not self.slider.value_changed.is_connected(self._on_slider_value_changed):
		self.slider.value_changed.connect(self._on_slider_value_changed)
	if not self.view_button.pressed.is_connected(self.request_view.emit):
		self.view_button.pressed.connect(self.request_view.emit)


## Disconnects the internal signals for this node
func _disconnect_internal_signals():
	if self.slider.value_changed.is_connected(self._on_slider_value_changed):
		self.slider.value_changed.disconnect(self._on_slider_value_changed)
	if self.view_button.pressed.is_connected(self.request_view.emit):
		self.view_button.pressed.disconnect(self.request_view.emit)
