extends Node

var scenes = {
	"race_track": "res://racetrack.tscn",
	"title_screen": "res://TitleScreen.tscn",
	"defeat": "res://Screens/Defeat.tscn",
	"credits": "res://Screens/Credits.tscn",
}

#var scene_arr = [] #[0: "title_screen", 1: "racetrack"] etc
var current_level_name
var current_level
var next_level
var modulation = 0
var modulate_speed = 4
var fade_to_black = false

func _ready():
	#for key in scenes.keys():
	#	scene_arr.append(key)
	current_level_name = "title_screen"
	next_level = load(scenes[current_level_name]).instance()
	add_child(next_level)
	current_level = next_level
	connect_signals()

func _process(delta):
	fade(delta)
	
func _physics_process(delta):
	pass
	# $TitleTrackROADARK.volume_db.lerp

func load_scene(scene_name):
	fade_to_black = true
	yield(get_tree().create_timer(1), "timeout")
	current_level.queue_free()
	current_level_name = scene_name
	next_level = load(scenes[current_level_name]).instance()
	add_child(next_level)
	current_level = next_level
	connect_signals()
	yield(get_tree().create_timer(2), "timeout")
	fade_to_black = false

func connect_signals():
	if not current_level.is_connected("next_level",self, "_next_level"):
		current_level.connect("next_level", self, "_next_level")
	if not current_level.is_connected("play_next_song",self, "_play_next_song"):
		current_level.connect("play_next_song", self, "_play_next_song")
	if not current_level.is_connected("restart_level",self, "_restart_level"):
		current_level.connect("restart_level", self, "_restart_level")
	if not current_level.is_connected("go_to_menu",self, "_go_to_menu"):
		current_level.connect("go_to_menu", self, "_go_to_menu")
	if not current_level.is_connected("car_die",self, "_go_to_defeat"):
		current_level.connect("car_die", self, "_go_to_defeat")
	if not current_level.is_connected("end_credits",self, "_go_to_defeat"):
		current_level.connect("end_credits", self, "_go_to_menu")
			
func _go_to_defeat(): 
	load_scene("defeat")	
	
func _restart_level():
	load_scene("race_track")
	
func _go_to_menu():
	load_scene("title_screen")
	
func _next_level():
	if current_level_name == "title_screen":
		load_scene("race_track")
	else: 
		print("Not sure what scene to load")
		load_scene("defeat")
	
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
