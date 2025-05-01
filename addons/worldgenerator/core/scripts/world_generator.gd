@icon("res://addons/worldgenerator/assets/WorldGeneratorIcon.png")
class_name WorldGenerator extends Node2D
## Can be used to procedurally generate worlds in the form of [TileMapLayer] nodes
##
## @experimental

const DEFAULT_TILESET := preload("res://addons/worldgenerator/assets/tilesets/default_hex_borderless.tres")

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


## Uses the current configuration settings to create and return a[br]
## procedurally generated hex-tile world in the form of a [TileMapLayer][br]
## node.
##
## [b]Note:[/b] This method does [u]not[/] add the resulting world to the[br]
## scene tree.
func generate_world() -> TileMapLayer:
	# Sample Noise
	var dims := self.get_dimensions()
	self._create_temp_world()
	var height_sample := NoiseSample.new(dims.x, dims.y)
	var heat_sample := NoiseSample.new(dims.x, dims.y)
	var moisture_sample := NoiseSample.new(dims.x, dims.y)
	if self.world_wrap:
		height_sample.sample_with_wrap(self.height_noise)
		heat_sample.sample_with_wrap(self.heat_noise)
		moisture_sample.sample_with_wrap(self.moisture_noise)
	else:
		height_sample.sample(self.height_noise)
		heat_sample.sample(self.heat_noise)
		moisture_sample.sample(self.moisture_noise)

	# Calculate Percentiles/Cutoffs
	var percentages: PackedFloat32Array = [float(self.water_percentage) / 100.0]
	var water_cutoff: float = height_sample.get_percentiles(percentages)[0]
	var weights: PackedInt32Array = [self.cold, self.mild, self.hot]
	percentages = WorldGeneratorUtils.percentiles_from_weights(weights)
	var heat_cutoffs := heat_sample.get_percentiles(percentages)
	weights = [self.arid, self.temperate, self.humid]
	percentages = WorldGeneratorUtils.percentiles_from_weights(weights)
	var moisture_cutoffs := moisture_sample.get_percentiles(percentages)

	# Perform Augments
	if self.cold_poles:
		var inflection_one: int = floori(dims.y / 4)
		var inflection_two: int = inflection_one * 2
		var inflection_three: int = inflection_one * 3
		var max_augment: float = (heat_cutoffs[1] - heat_cutoffs[0]) * 4.0
		# Note: Captures are by reference - NOT thread safe
		var augment := func(x: int, y: int, old_value: float) -> float:
			var new_value: float
			var augment_strength: float
			var fy := float(y)
			var inflection_delta := float(inflection_one)
			if y < inflection_one:
				augment_strength = 1.0 - (fy / inflection_delta)
				new_value = old_value - (max_augment * augment_strength)
			elif y < inflection_two:
				augment_strength = ((fy - inflection_delta) / inflection_delta)
				new_value = old_value + (max_augment * augment_strength)
			elif y < inflection_three:
				augment_strength = 1.0 - ((fy - (inflection_delta * 2.0)) / inflection_delta)
				new_value = old_value + (max_augment * augment_strength)
			else:
				augment_strength = ((fy - (inflection_delta * 3.0)) / inflection_delta)
				new_value = old_value - (max_augment * augment_strength)
			return new_value
		heat_sample.augment_sample(augment)

		# Recalculate Cutoffs
		weights = [self.cold, self.mild, self.hot]
		percentages = WorldGeneratorUtils.percentiles_from_weights(weights)
		heat_cutoffs = heat_sample.get_percentiles(percentages)

	# Insert Tiles
	var world_coords := Vector2i(0, 0)
	var atlas_coords := Vector2i(0, 0)
	var heat: float
	var moisture: float
	for y in range(dims.y):
		world_coords.y = y
		for x in range(dims.x):
			world_coords.x = x
			if height_sample.get_value(world_coords) < water_cutoff: # Water
				atlas_coords.x = 3
				atlas_coords.y = 2
			else: # Land
				heat = heat_sample.get_value(world_coords)
				if heat < heat_cutoffs[0]:
					atlas_coords.y = 2 # {tundra, boreal, snow}
				elif heat < heat_cutoffs[1]:
					atlas_coords.y = 1 # {plains, forest, swamp}
				else:
					atlas_coords.y = 0 # {desert, savannah, jungle}
				moisture = moisture_sample.get_value(world_coords)
				if moisture < moisture_cutoffs[0]:
					atlas_coords.x = 0 # {desert, plains, tundra}
				elif moisture < moisture_cutoffs[1]:
					atlas_coords.x = 1 # {savannah, forest, boreal}
				else:
					atlas_coords.x = 2 # {jungle, swamp, snow}
			self.world.set_cell(world_coords, 0, atlas_coords)
	return self.world


func _create_temp_world():
	self.world = TileMapLayer.new()
	self.world.tile_set = DEFAULT_TILESET
