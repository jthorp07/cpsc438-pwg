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


## Populates this sample by sampling 2D noise from [param noise]
func sample(noise: FastNoiseLite):
	for y in range(self._height):
		for x in range(self._width):
			self._sample[y][x] = noise.get_noise_2d(x, y)


## Populates this sample by sampling 3D noise from [param noise] in such[br]
## a way that an isometric sample is collected with the exception of the[br]
## sample seamlessly wrapping on the Y axis (left to right)
func sample_with_wrap(noise: FastNoiseLite):
	var fwidth: float = float(self._width)
	var fheight: float = float(self._height)
	var radius: float = fwidth / TAU
	for y in range(self._height):
		for x in range(self._width):
			var radians: float = TAU * float(x) / fwidth
			var nx: float = radius * cos(radians)
			var ny: float = radius * sin(radians)
			var nz: float = y
			self._sample[y][x] = noise.get_noise_3d(nx, ny, nz)


## Retrieve this sample's dimensions as a [class Vector2i]
func dimensions() -> Vector2i:
	return Vector2i(self._width, self._height)


## Retrieve the value at [param coords]
func get_value(coords: Vector2i):
	return self._sample[coords.y][coords.x]


## Iterates over all sample values performing an augment specified by [param augment].[br]
## Augments are calculated based on the X and Y coordinates and current value at[br]
## those coordinates.[br][br]
## Expects that [param augment] is of signature:[br][br]
## [code]func augment(x: int, y: int, old_value: float) -> float[/code][br]
func augment_sample(augment: Callable):
	for y in range(self._height):
		for x in range(self._width):
			self._sample[y][x] = augment.call(x, y, self._sample[y][x])


## Creates a 1 dimensional array with every value in this sample in ascending order
func _to_sorted_array() -> PackedFloat32Array:
	var arr: PackedFloat32Array = []
	arr.resize(self._width * self._height)
	for y in range(self._height):
		for x in range(self._width):
			arr[(self._width * y) + x] = self._sample[y][x]
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
		var sample_index := roundi(float(max_index) * clampf(percentiles[i], 0.00, 1.00))
		results[i] = sample[sample_index]
	return results
