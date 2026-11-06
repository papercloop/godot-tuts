extends RefCounted
class_name Bob

const fast_speed: float = 22.0
const med_speed: float = 14.0
const slow_speed: float = 10.0

const high_intensity: float = 0.2
const med_intensity: float = 0.1
const low_intensity: float = 0.05

var frequency: float = 2.0
var ratio: float = 0.5

var object_to_bob: Node3D
var current_intensity: float = 0.0
var current_speed: float = 0.0
var bobbing_vector: Vector2 = Vector2.ZERO
var index: float = 0.0

func setBob(on_node: Node3D, mode: String) -> void:
	object_to_bob = on_node
	if mode == "walking":
		current_intensity = med_intensity
		current_speed = med_speed
	elif mode == "crouching":
		current_intensity = low_intensity
		current_speed = slow_speed
	elif mode == "sprinting": 
		current_intensity = high_intensity
		current_speed = fast_speed
	elif mode == "none":
		current_intensity = 0.0
		current_speed = 0.0



func getBobLocation(on_node: Node3D, _delta: float, moving: bool, lerp_speed: float) -> Vector2:
	prints("moving: ", moving)
	index += current_speed * _delta

	bobbing_vector.y = sin(index)
	bobbing_vector.x = (sin(index / frequency) + ratio)

	var return_vector = Vector2.ZERO

	if moving: 
		return_vector.y = lerp(on_node.position.y, bobbing_vector.y * (current_intensity / frequency), _delta * lerp_speed)
		return_vector.x = lerp(on_node.position.x, bobbing_vector.x * current_intensity, _delta * lerp_speed)
	else:
		return_vector.y = lerp(on_node.position.y, 0.0, _delta * lerp_speed)
		return_vector.x = lerp(on_node.position.x, 0.0, _delta * lerp_speed)
	
	return return_vector

	
