@tool
class_name WorldGeneratorDockToggleOptions extends VBoxContainer

signal world_wrap_changed(new_value: bool)
signal cold_poles_changed(new_value: bool)

var world_wrap: BooleanOption
var cold_poles: BooleanOption
var members_created: bool = false
var children_added: bool = false

func _init():
	self._create_members()
	self._add_child_nodes()
	self._connect_internal_signals()


func clean_up():
	self._disconnect_internal_signals()
	self._remove_child_nodes()
	self._free_members()


## Creates the internal nodes and member instances for this node
func _create_members():
	if self.members_created:
		return
	self.world_wrap = BooleanOption.new(&"World Wrap")
	self.world_wrap.name = &"WorldWrap"
	self.cold_poles = BooleanOption.new(&"Cold Poles")
	self.cold_poles.name = &"ColdPoles"
	# Finish
	self.members_created = true


## Adds appropriate child nodes to this node
func _add_child_nodes():
	if self.children_added:
		return
	add_child(self.world_wrap)
	add_child(self.cold_poles)
	self.children_added = true


## Remove appropriate child nodes from this node
func _remove_child_nodes():
	if not self.children_added:
		return
	self.remove_child.call_deferred(self.world_wrap)
	self.remove_child.call_deferred(self.cold_poles)
	self.children_added = false


## Frees the members of this node
func _free_members():
	# Don't free if members not initialized
	if not self.members_created:
		return
	# Don't free if members still in scene tree
	if self.children_added:
		return
	self.world_wrap.queue_free()
	self.cold_poles.queue_free()
	self.members_created = false


## Connects the internal signals for this node
func _connect_internal_signals():
	if not self.world_wrap.value_changed.is_connected(self.world_wrap_changed.emit):
		self.world_wrap.value_changed.connect(self.world_wrap_changed.emit)
	if not self.cold_poles.value_changed.is_connected(self.cold_poles_changed.emit):
		self.cold_poles.value_changed.connect(self.cold_poles_changed.emit)


## Disconnects the internal signals for this node
func _disconnect_internal_signals():
	if self.world_wrap.value_changed.is_connected(self.world_wrap_changed.emit):
		self.world_wrap.value_changed.disconnect(self.world_wrap_changed.emit)
	if self.cold_poles.value_changed.is_connected(self.cold_poles_changed.emit):
		self.cold_poles.value_changed.disconnect(self.cold_poles_changed.emit)
