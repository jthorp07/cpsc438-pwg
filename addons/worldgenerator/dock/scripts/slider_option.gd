@tool
class_name SliderOption
extends VBoxContainer

signal value_updated

# Scene Nodes
var label: Label
var spinbox: SpinBox
# Internal
var children_added: bool = false
var members_created: bool = false

func _init(label_text: String, default_value: float):
	self._create_members(label_text, default_value)
	self._add_child_nodes()
	self._connect_internal_signals()
	print(&"SliderOption Initialized")


func clean_up():
	self._disconnect_internal_signals()
	self._remove_child_nodes()
	self._free_members()
	print(&"SliderOption Cleaned Up")


## Retrieve the value from this option's slider
func get_value() -> int:
	return self.spinbox.value


## Creates the internal nodes and member instances for this node
func _create_members(label_text: String, default_value: float):
	if self.members_created:
		return
	# Label
	self.label = Label.new()
	self.label.text = label_text
	self.label.name = &"Label"
	# SpinBox
	self.spinbox = SpinBox.new()
	self.spinbox.set_value_no_signal(default_value)
	self.spinbox.update_on_text_changed = true
	self.spinbox.step = 1
	self.spinbox.max_value = 10
	self.spinbox.min_value = 0
	# Finish
	self.members_created = true
	self.spinbox.name = &"SpinBox"
	# print(&"Members Created")


## Adds appropriate child nodes to this node
func _add_child_nodes():
	if self.children_added:
		return
	add_child(label)
	add_child(spinbox)
	self.children_added = true
	# print(&"Children Added")


## Remove appropriate child nodes from this node
func _remove_child_nodes():
	if not self.children_added:
		return
	self.remove_child.call_deferred(self.label)
	self.remove_child.call_deferred(self.spinbox)
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
	self.spinbox.queue_free()
	self.members_created = false
	# print(&"Members Freed")


## Connects the internal signals for this node
func _connect_internal_signals():
	if not self.spinbox.value_changed.is_connected(self.value_updated.emit):
		self.spinbox.value_changed.connect(self.value_updated.emit)


## Disconnects the internal signals for this node
func _disconnect_internal_signals():
	if self.spinbox.value_changed.is_connected(self.value_updated.emit):
		self.spinbox.value_changed.disconnect(self.value_updated.emit)
