extends RigidBody2D

var zombie_sounds = []
var timer = Timer.new()
const SOUND_DIR = "res://Assets/Sounds/Zombie/"
var idle_distance = 1000  # The distance at which the zombie starts moving towards the car
var zombie_top_speed = 500  # The maximum speed of the zombie
var zombie_acceleration_factor = 10
var is_attacking = false
var player_car
var speed_to_kill = 500
var zombie_death_time = 0.1
var Bloodsplat = preload("Bloodsplat.tscn")
var is_dead = false

# Preload the zombie sound effects
func _ready():
	zombie_top_speed = rand_range(100, 500)
	zombie_top_speed = 0
	$AnimatedSprite.play("move")
	linear_damp = 1
	player_car = get_parent().get_parent().get_node("Car")

	var dir = Directory.new()
	if dir.open(SOUND_DIR) == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".mp3"):
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
	$AudioStreamPlayer2D.stream = zombie_sounds[randi() % zombie_sounds.size()]
	$AudioStreamPlayer2D.play()

	# Reset the timer
	timer.wait_time = rand_range(1, 5)
	timer.start()

func _physics_process(_delta):
	var car_position = player_car.global_position
	var distance = global_position.distance_to(car_position)
	# if distance > idle_distance:
	#     idle()
	# else:
	if is_attacking:
		var direction_to_zombie = (position - player_car.position).normalized()
		var speed_to_zombie = player_car.linear_velocity.dot(direction_to_zombie)
		if speed_to_zombie >= speed_to_kill and not is_dead:
			is_dead = true
			var bloodsplat = Bloodsplat.instance()
			get_parent().add_child(bloodsplat)
			bloodsplat.position = position
			bloodsplat.rotation = rad2deg(player_car.linear_velocity.angle())
			yield(get_tree().create_timer(zombie_death_time), "timeout")
			player_car.hit_zombie()
			queue_free()
	else:
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
	# Move Zombie3 towards the Car by updating its position.
	global_position += direction * 0.7

	# Rotate Zombie3 to face the Car.
	rotation = atan2(direction.y, direction.x)

func _on_Area2D_area_entered(area):
	is_attacking = true
	$AnimatedSprite.play("attack")

func _on_Area2D_area_exited(area):
	$AnimatedSprite.play("move")
	is_attacking = false
