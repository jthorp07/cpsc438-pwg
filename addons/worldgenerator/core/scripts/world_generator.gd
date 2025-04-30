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
@export var height_noise: FastNoiseLite = FastNoiseLite.new()
@export var moisture_noise: FastNoiseLite = FastNoiseLite.new()
@export var heat_noise: FastNoiseLite = FastNoiseLite.new()

## Temporary variable to store the world during generation
var world: TileMapLayer = null

## Retrieve the dimensions set for world generation. Dimensions are 2 raised
## to the power of the width and height member fields.
func get_dimensions() -> Vector2i:
	return Vector2i(2 ** self.width, 2 ** self.height)


func generate_world():
	# TODO: Template algorithm:
	# 1. Sample Noise
	self.world = TileMapLayer.new()
	var dims := self.get_dimensions()
	var height_map := NoiseSample.new(dims.x, dims.y)
	var heat_map := NoiseSample.new(dims.x, dims.y)
	var moisture_map := NoiseSample.new(dims.x, dims.y)
	if self.world_wrap:
		height_map.sample_with_wrap(self.height_noise)
		heat_map.sample_with_wrap(self.heat_noise)
		moisture_map.sample_with_wrap(self.moisture_noise)
	else:
		height_map.sample(self.height_noise)
		heat_map.sample(self.heat_noise)
		moisture_map.sample(self.moisture_noise)
	# 2. Calculate Percentiles/Cutoffs
	var percentages: PackedFloat32Array = [float(self.water_percentage) / 100.0]
	var water_cutoff: float = height_map.get_percentiles(percentages)[0]
	percentages = []
	# 3. Perform Augments
	# 4. Recalculate Cutoffs
	# 5. Insert Tiles


func place_tile(height_map: NoiseSample, heat_map: NoiseSample, moisture_map: NoiseSample, coords: Vector2i):
	# TODO: Set atlas coords appropriately
	
	var atlas_coords = Vector2i(1, 0)
	self.world.set_cell(coords, 0, atlas_coords)
	pass


func _create_temp_world():
	self.world = TileMapLayer.new()
	self.world.tile_set = HEX_TEST_TILESET


func _percentiles_from_weights(weights: PackedInt32Array) -> PackedFloat32Array:
	var res: PackedFloat32Array = []
	
	return res
