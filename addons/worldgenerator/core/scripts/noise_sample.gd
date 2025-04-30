@tool
class_name NoiseSample

var _width: int
var _height: int
var _sample: Array[PackedFloat32Array]

func _init(width: int, height: int):
	self._width = width
	self._height = height
	self._sample = []
	self._sample.resize(height)
	var row: PackedFloat32Array = []
	row.resize(width)
	row.fill(0.0)
	for i in range(height):
		self._sample[i] = PackedFloat32Array(row)


## Populates this sample by sampling 2D noise from `noise`
func sample(noise: FastNoiseLite):
	for y in range(self._height):
		for x in range(self._width):
			self._sample[y][x] = noise.get_noise_2d(x, y)


## Populates this sample by sampling 3D noise from `noise` in using[br]
## a cylindrical formula that results in seamless horizontal wrapping
func sample_with_wrap(noise: FastNoiseLite):
	var fwidth: float = float(self._width)
	var fheight: float = float(self._height)
	for y in range(self._height):
		for x in range(self._width):
			# Sinusoidal functions with period=width and amplitude=width/2
			# Makes the looper still move 1 on each axis for each sample value & wrap on one axis
			var nx = fwidth / 2.0 * cos((TAU * float(x)) / fwidth)
			var ny = fwidth / 2.0 * sin((TAU * float(y)) / fwidth)
			var nz = y
			self._sample[y][x] = noise.get_noise_3d(nx, ny, nz)


func dimensions() -> Vector2i:
	return Vector2i(self._width, self._height)


func _to_sorted_array() -> PackedFloat32Array:
	var arr: PackedFloat32Array = []
	arr.resize(self._width * self._height)
	for y in range(self._height):
		for x in range(self._width):
			arr[(x * y) + y] = self._sample[y][x]
	arr.sort()
	return arr


## Calculates and returns the value at each of `percentiles`' percentiles[br]
## Percentiles are restricted to the nearest percent and are expected to[br]
## be between 0.00 and 1.00
func get_percentiles(percentiles: PackedFloat32Array) -> PackedFloat32Array:
	var sample := self._to_sorted_array()
	var results: PackedFloat32Array = []
	var count := percentiles.size()
	var max_index: int = (self._width * self._height) - 1
	results.resize(count)
	for i in range(count):
		results[i] = sample[roundi(float(max_index) * clampf(percentiles[i], 0.00, 1.00))]
	return results
