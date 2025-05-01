extends Node2D

@onready var world_generator := $WorldGenerator

var tile_map_layer: TileMapLayer

func _ready():
	if world_generator is WorldGenerator:
		tile_map_layer = world_generator.generate_world() as TileMapLayer
		tile_map_layer.name = "World"
		add_child(tile_map_layer)
