extends Node2D


var ambient_energy = 0.03
var flash_energy = 1

var time_til_next_lightning = 20
var time_between_lightning_min = 10
var time_between_lightning_max = 30

var is_lightning = false
var lightning_time = 0
var lightning_end_time = 1

var is_flashing = false
var flashing_time = 0
var flash_length = 0.6
var time_til_next_flash = 0
var time_between_flash_min = 0.3
var time_between_flash_max = 0.8

func _ready():
	is_lightning = false
	
func _process(delta):
	if is_lightning: 
		if lightning_time < lightning_end_time:
			lightning_time += delta
			flash(delta)
		else:
			is_lightning = false
			lightning_time = 0
			time_til_next_lightning = rand_range(time_between_lightning_min, time_between_lightning_max)
			time_til_next_flash = 0
			visible = false
			$Thunder.play()
	else: # not is_lightning 
		if time_til_next_lightning >= 0:
			time_til_next_lightning -= delta
		else: 
			is_lightning = true


			
func flash(delta): 
	if is_flashing: 
		if flashing_time < flash_length:
			flashing_time += delta
			visible = true
		else:
			is_flashing = false
			flashing_time = 0
			visible = false
	else: # not is_lightning 
		if time_til_next_flash >= 0:
			time_til_next_flash -= delta
		else: 
			is_flashing = true
			flashing_time = 0
			time_til_next_flash = rand_range(time_between_flash_min, time_between_flash_max)
