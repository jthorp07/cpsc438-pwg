@tool
extends EditorPlugin

# Editor node constants
const NODE_NAME = "WorldGenerator"
const INHERITANCE = "Node2D"
const NODE_SCRIPT = preload("editor/worldgenerator.gd")
const NODE_ICON = preload("assets/WorldGeneratorIcon.png")

func _enter_tree():
	add_custom_type(NODE_NAME, INHERITANCE, NODE_SCRIPT, NODE_ICON)


func _exit_tree():
	remove_custom_type(NODE_NAME)
