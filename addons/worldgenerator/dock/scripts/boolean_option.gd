@tool
class_name BooleanOption extends HBoxContainer

signal value_changed(new_value: bool)

var label: Label
var checkbox: CheckBox
var members_created: bool = false
var children_added: bool = false

func _init(label_name: String):
	self._create_members(label_name)
	self._add_child_nodes()
	self._connect_internal_signals()


func clean_up():
	self._disconnect_internal_signals()
	self._remove_child_nodes()
	self._free_members()


## Creates the internal nodes and member instances for this node
func _create_members(label_text: String):
	if self.members_created:
		return
	# Label
	self.label = Label.new()
	self.label.text = label_text
	self.label.name = &"Label"
	# CheckBox
	self.checkbox = CheckBox.new()
	# Finish
	self.members_created = true
	self.checkbox.name = &"CheckBox"
	# print(&"Members Created")


## Adds appropriate child nodes to this node
func _add_child_nodes():
	if self.children_added:
		return
	add_child(self.label)
	add_child(self.checkbox)
	self.children_added = true
	# print(&"Children Added")


## Remove appropriate child nodes from this node
func _remove_child_nodes():
	if not self.children_added:
		return
	self.remove_child.call_deferred(self.label)
	self.remove_child.call_deferred(self.checkbox)
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
	self.checkbox.queue_free()
	self.members_created = false
	# print(&"Members Freed")


## Connects the internal signals for this node
func _connect_internal_signals():
	if not self.checkbox.toggled.is_connected(self.value_changed.emit):
		self.checkbox.toggled.connect(self.value_changed.emit)


## Disconnects the internal signals for this node
func _disconnect_internal_signals():
	if self.checkbox.toggled.is_connected(self.value_changed.emit):
		self.checkbox.toggled.disconnect(self.value_changed.emit)
