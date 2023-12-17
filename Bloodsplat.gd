extends Node2D


var modulation = 1.0
var color_modulation = 1.0
var modulation_factor = 4
var lifetime = 10
var start_fading_after = 5
var timer = 0

func _ready():
	yield(get_tree().create_timer(lifetime), "timeout")
	queue_free()

func _process(delta):
	timer += delta
	if color_modulation > 0.5:
		color_modulation -= delta / (modulation_factor * 3)
	if timer > start_fading_after:
		modulation -= delta / modulation_factor
	modulate = Color(color_modulation, color_modulation, color_modulation, modulation)
