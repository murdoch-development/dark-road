extends Node2D

signal end_credits

var is_fading = false
var modulate_time = 0
export var max_modulate_time = 5

func _ready(): 
	$AudioStreamPlayer.playing = true
	
func _process(delta): 
	if is_fading: 
		if modulate_time < max_modulate_time:
			modulate_time += delta
			var col = 1 - (modulate_time / max_modulate_time)
			modulate = Color(col,col,col)
		else: 
			emit_signal("end_credits")

func _on_Text_end_credits():
	is_fading = true
