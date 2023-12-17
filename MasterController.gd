extends Node


var scenes = {
	 "title_screen": "res://TitleScreen.tscn",
	 "race_track": "res://racetrack.tscn",
}

var scene_arr = [] #[0: "title_screen", 1: "racetrack"] etc
var current_level
var next_level
var scene_index = 0
var modulation = 0
var modulate_speed = 4
var fade_to_black = false

func _ready():
	var i = 0
	for key in scenes.keys():
		scene_arr.append(key)
	next_level = load(scenes[scene_arr[scene_index]]).instance()
	add_child(next_level)
	current_level = next_level
	connect_signals()

func _process(delta):
	fade(delta)

func load_scene(scene_name):
	fade_to_black = true
	yield(get_tree().create_timer(1), "timeout")
	current_level.queue_free()
	next_level = load(scenes[scene_name]).instance()
	add_child(next_level)
	current_level = next_level
	connect_signals()
	yield(get_tree().create_timer(2), "timeout")
	fade_to_black = false

func connect_signals():
	current_level.connect("next_level", self, "_next_level")
	current_level.connect("play_next_song", self, "_play_next_song")

func _next_level():
	scene_index += 1
	load_scene(scene_arr[scene_index])
	
func _play_next_song():
	$MetalBand/TitleTrackROADARK.play()

func fade(delta):
	if fade_to_black and modulation < 1:
		modulation += delta * modulate_speed
		if modulation > 1:
			modulation = 1
	elif not fade_to_black and modulation > 0:
		modulation -= delta * modulate_speed
		if modulation < 0:
			modulation = 0
	$Blackout.modulate = Color(1, 1, 1, modulation)
