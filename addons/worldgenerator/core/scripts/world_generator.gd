@icon("res://addons/worldgenerator/assets/WorldGeneratorIcon.png")
class_name WorldGenerator extends Node2D

const HEX_TEST_TILESET := preload("res://addons/worldgenerator/assets/tilesets/hex_test.tres")
# TODO: Need 3x3 biomes + water TileSet

@export_group("World Configuration")
## Height of the world in powers of 2 tiles
@export_range(1, 10) var height: int = 1
## Width of the world in powers of 2 tiles
@export_range(1, 10) var width: int = 1
## If true, world will wrap horizontally
@export var world_wrap: bool = false
## If true, the top and bottom of the world will generally be colder[br]
## than the middle.
@export var cold_poles: bool = false
## The percentage of tiles that should be water. Non-water tiles will[br]
## be land tiles.
@export_range(1, 100) var water_percentage: int = 60
@export_subgroup("Temperature")
## Weight to use when calculating cutoffs for cold tiles
@export_range(0, 10) var cold: int = 1
## Weight to use when calculating cutoffs for mild tiles
@export_range(0, 10) var mild: int = 1
## Weight to use when calculating cutoffs for hot tiles
@export_range(0, 10) var hot: int = 1
@export_subgroup("Humidity")
## Weight to use when calculating cutoffs for arid tiles
@export_range(0, 10) var arid: int = 1
## Weight to use when calculating cutoffs for temperate tiles
@export_range(0, 10) var temperate: int = 1
## Weight to use when calculating cutoffs for humid tiles
@export_range(0, 10) var humid: int = 1

@export_group("Noise Configuration")
@export var height_noise: FastNoiseLite
@export var moisture_noise: FastNoiseLite
@export var heat_noise: FastNoiseLite

## Temporary variable to store the world during generation
var world: TileMapLayer = null

## Retrieve the dimensions set for world generation. Dimensions are 2 raised
## to the power of the width and height member fields.
func get_dimensions() -> Vector2i:
	return Vector2i(2 ** self.width, 2 ** self.height)


func generate_world():
	# TODO: Template algorithm:
	# 1. Sample Noise
	# 2. Calculate Percentiles/Cutoffs
	# 3. Perform Augments
	# 4. Recalculate Cutoffs
	# 5. Insert Tiles
	self.world = TileMapLayer.new()
	if world_wrap:
		var height_map := sample_each_coord_with_wrap(height_noise)
		var moisture_map := sample_each_coord_with_wrap(moisture_noise)
		var heat_map := sample_each_coord_with_wrap(heat_noise)
	else:
		var height_map := sample_each_coord(height_noise)
		var moisture_map := sample_each_coord(moisture_noise)
		var heatmap := sample_each_coord(heat_noise)


## Returns a 2D array of floating point values resulting from cylindrically
## sampling noise values
func sample_each_coord_with_wrap(noise: FastNoiseLite) -> Array[Array]:
	var results = Array()
	var delta_rotation_x: float = TAU / float(width)
	var delta_rotation_y: float = TAU / float(height)
	var fwidth: float = float(width)
	var fheight: float = float(height)
	for x in range(2 ** width):
		for y in range(2 ** height):
			# Sinusoidal functions with period=width and amplitude=width/2
			# Makes the looper still move 1 on each axis for each sample value & wrap on one axis
			var nx = fwidth / 2.0 * cos((TAU * float(x)) / fwidth)
			var ny = fwidth / 2.0 * sin((TAU * float(y)) / fwidth)
			var nz = y
			results[x].append(noise.get_noise_3d(nx, ny, nz))
	return results


## Returns a 2D array of floating point values resulting from sampling noise
## values
func sample_each_coord(noise: FastNoiseLite) -> Array[Array]:
	var results := Array()
	for x in range(width):
		for y in range(height):
			results[x].append(noise.get_noise_2d(x, y))
	return results


func place_tile(height_map: Array[Array], heat_map: Array[Array], moisture_map: Array[Array], coords: Vector2i):
	# TODO: Set atlas coords appropriately
	
	var atlas_coords = Vector2i(1, 0)
	self.world.set_cell(coords, 0, atlas_coords)
	pass


func _create_temp_world():
	self.world = TileMapLayer.new()
	self.world.tile_set = HEX_TEST_TILESET
