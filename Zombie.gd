extends RigidBody2D

var zombie_sounds = []
var timer = Timer.new()

# Preload the zombie sound effects
func _ready():
	var dir = Directory.new()
	if dir.open("res://ZOMBIE SFX/ZOMBIE SFX/") == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".wav") or filename.ends_with(".ogg"):
				zombie_sounds.append(load("res://ZOMBIE SFX/ZOMBIE SFX/" + filename))
			filename = dir.get_next()
		dir.list_dir_end()

	# Initialize and start the timer
	add_child(timer)
	timer.wait_time = rand_range(1, 5)
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start()

func _on_Timer_timeout():
	# Play a random sound
	var sound_player = AudioStreamPlayer2D.new()
	add_child(sound_player)
	sound_player.stream = zombie_sounds[randi() % zombie_sounds.size()]
	sound_player.play()

	# Adjust volume based on distance to Listener2D
	var listener = get_node_or_null("/root/Listener2D")  # Replace with the actual path to your Listener2D
	if listener:
		var distance = global_position.distance_to(listener.global_position)
		sound_player.volume_db = -distance  # Adjust this formula as needed

	# Reset the timer
	timer.wait_time = rand_range(1, 5)
	timer.start()
