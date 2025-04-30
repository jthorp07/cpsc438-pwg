@tool
class_name WorldGeneratorUtils extends Node

static func sample_noise(width: int, height: int, noise: FastNoiseLite, seamless: bool = false) -> NoiseSample:
	var sample := NoiseSample.new(width, height)
	if seamless:
		sample.sample_with_wrap(noise)
	else:
		sample.sample(noise)
	return sample


static func percentiles_from_weights(weights: PackedInt32Array) -> PackedFloat32Array:
	var percentiles: PackedFloat32Array = []
	percentiles.resize(weights.size() - 1)
	var total_weight: int = 0
	for i in range(weights.size()):
		total_weight += weights[i]
	var cumulative_weight: int = 0
	for i in range(weights.size() - 1):
		cumulative_weight += weights[i]
		percentiles[i] = float(cumulative_weight) / float(total_weight)
	printraw("Percentiles:")
	for i in range(percentiles.size()):
		printraw(" %.2f")
	printraw("\n")
	return percentiles
