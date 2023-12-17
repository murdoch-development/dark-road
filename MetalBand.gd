extends Node

var soundtracks = ["res://Assets/Sounds/Music/RoadArk-_Title_Track_-_V2.mp3", "res://Assets/Sounds/Music/cult_of_the_skull.mp3", "res://Assets/Sounds/Music/xenomorph.mp3", "res://Assets/Sounds/Music/haunting_of_the_flesh.mp3", "res://Assets/Sounds/Music/plauge_rat.mp3"]

var current_soundtrack = 0
var audio_stream_player
var last_played = 0
onready var initial_db = 0
onready var rng = RandomNumberGenerator.new()

func _ready():
	print("sounds: ", soundtracks.size())
	
	rng.randomize()
	audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.volume_db = -12
	add_child(audio_stream_player)

func _process(delta):
	var cur_level = get_parent().current_level_name
	if cur_level != "title_screen" and audio_stream_player.volume_db >=  -14:
		audio_stream_player.volume_db -= delta * 10
	if Input.is_action_just_pressed("next_song"):
		switch_soundtrack(-1)


func switch_soundtrack(index):
	if index < 0 or index >= soundtracks.size():
		index = rng.randi_range(0, soundtracks.size() - 1)
		if index == last_played:
			index += 1
			if index == soundtracks.size():
				index = 0
		
	last_played = index
	current_soundtrack = index

	var soundtrack = load(soundtracks[current_soundtrack])

	if audio_stream_player.playing:
		audio_stream_player.stop()

	audio_stream_player.stream = soundtrack
	audio_stream_player.play()
