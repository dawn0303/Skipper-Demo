extends OmniLight3D

@export var noise : NoiseTexture2D
@export var energyMult : float
@export var speedMult : float
var time_passed = 0
var sampled_noise 

func _process(delta: float) -> void:
	time_passed += delta
	sampled_noise = noise.noise.get_noise_1d(time_passed*speedMult)
	sampled_noise = abs(sampled_noise)
	
	light_energy = (sampled_noise*energyMult)+energyMult
