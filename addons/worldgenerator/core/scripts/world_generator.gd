class_name WorldGenerator extends Node2D

@export_group("World Configuration")
## Height of the world in powers of 2 tiles
@export_range(1, 10) var height: int = 1
## Width of the world in powers of 2 tiles
@export_range(1, 10) var width: int = 1
## A value of 1 will yield all land[br]
## A value of 10 will yield all water
@export_range(1, 10) var water_level: float = 5
## If true, world will wrap horizontally
@export var world_wrap: bool = false
@export_group("Noise Configuration")
@export var height_noise: FastNoiseLite = FastNoiseLite.new()
@export var moisture_noise: FastNoiseLite = FastNoiseLite.new()
@export var heat_noise: FastNoiseLite = FastNoiseLite.new()

## Retrieve the dimensions set for world generation. Dimensions are 2 raised
## to the power of the width and height member fields.
func get_dimensions() -> Vector2i:
	return Vector2i(2 ** self.width, 2 ** self.height)


func generate_world():
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
	for x in range(width ** 2):
		for y in range(height ** 2):
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
