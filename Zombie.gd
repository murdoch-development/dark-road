extends RigidBody2D

var zombie_sounds = []
var timer = Timer.new()
const SOUND_DIR = "res://Assets/Sounds/Zombie/"
var car_node: RigidBody2D
var idle_distance = 1000  # The distance at which the zombie starts moving towards the car
var zombie_top_speed = 200  # The maximum speed of the zombie
var zombie_acceleration_factor = 1

# Preload the zombie sound effects
func _ready():
	car_node = get_parent().get_parent().get_node("Car")
	linear_damp = 1

	var dir = Directory.new()
	if dir.open(SOUND_DIR) == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".wav") or filename.ends_with(".ogg"):
				zombie_sounds.append(load(SOUND_DIR + filename))
			filename = dir.get_next()
		dir.list_dir_end()
		# Initialize and start the timer
		add_child(timer)
		timer.wait_time = rand_range(1, 5)
		timer.connect("timeout", self, "_on_Timer_timeout")
		timer.start()

func _on_Timer_timeout():
		play_random_sound()

func play_random_sound():
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

func _physics_process(_delta):
	var car_position = car_node.global_position
	var distance = global_position.distance_to(car_position)
	# if distance > idle_distance:
	#     idle()
	# else:
	move_towards_car(car_position)

func idle():
	$AnimatedSprite.play("idle")

func move_towards_car(car_position):
	# Calculate the direction vector from Zombie3 to the Car.
	var direction = (car_position - global_position).normalized()

	if(linear_velocity.length() >= zombie_top_speed):
		linear_damp = 10
	else:
		linear_damp = 1
	apply_central_impulse(direction * zombie_acceleration_factor)	
	print(linear_velocity.length())
	# Move Zombie3 towards the Car by updating its position.
	global_position += direction * 0.7

	# Rotate Zombie3 to face the Car.
	rotation = atan2(direction.y, direction.x)

	$AnimatedSprite.play("move")

func _on_Zombie_body_entered(body):
	if body == car_node:
			attack()


func attack():
	$AnimatedSprite.play("attack")
