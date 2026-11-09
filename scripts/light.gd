extends SpotLight3D

# when we want the light to turn on vs off:
@export var actuation_percentage: float = 0.8
@export var binary: bool = true

func execute(_percentage: float) -> void:
	if binary:
		if _percentage < actuation_percentage:
			visible = false
		else:
			visible = true
	else: 
		light_energy = _percentage * 100
		if visible == false:
			visible = true
		
