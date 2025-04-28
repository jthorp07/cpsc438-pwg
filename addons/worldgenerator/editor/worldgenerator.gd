@tool
extends Node2D

@export_group("World Configuration")
## Height of the world in powers of 2 tiles
@export_range(1, 10) var height: int = 1
## Width of the world in powers of 2 tiles
@export_range(1, 10) var width: int = 1
## A value of 1 will yield all land[br]
## A value of 10 will yield all water
@export_range(1, 10) var water_level: int = 5
## If true, world will wrap horizontally
@export var world_wrap: bool = false

func _enter_tree():
	pass

func generate_world():
	pass
