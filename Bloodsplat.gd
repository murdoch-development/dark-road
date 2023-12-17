extends Node2D


var modulation = 1.0
var modulation_factor = 4
var lifetime = 10
var start_modulation_after = 5
var timer = 0

func _ready():
	rotation = rand_range(0, 2 * PI) 
	yield(get_tree().create_timer(lifetime), "timeout")
	queue_free()

func _process(delta):
	timer += delta
	if timer > start_modulation_after:
		modulation -= delta / modulation_factor
		modulate = Color(1, 1, 1, modulation)
