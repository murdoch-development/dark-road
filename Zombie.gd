extends RigidBody2D

signal zombie_attack

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
		timer.wait_time = rand_range(15, 30)
		timer.connect("timeout", self, "_on_Timer_timeout")
		timer.start()

func _on_Timer_timeout():
		play_random_sound()

func play_random_sound():
	if ($AudioStreamPlayer2D.playing == false):
		$AudioStreamPlayer2D.stream = zombie_sounds[randi() % zombie_sounds.size()]
		$AudioStreamPlayer2D.play()

	# Reset the timer
	timer.wait_time = rand_range(15, 30)
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
			zombie_die()
	else:
		move_towards_car(car_position)

func zombie_die(): 
	is_dead = true
	var bloodsplat = Bloodsplat.instance()
	get_parent().add_child(bloodsplat)
	bloodsplat.position = position
	bloodsplat.rotation = rad2deg(player_car.linear_velocity.angle())

	yield(get_tree().create_timer(zombie_death_time), "timeout")
	player_car.hit_zombie()
	queue_free()

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
	if not is_attacking:
		is_attacking = true
		$AnimatedSprite.play("attack_ready")

func _on_Area2D_area_exited(area):
	$AnimatedSprite.play("move")
	is_attacking = false
	$SlamSound.playing = false

func _on_AnimatedSprite_animation_finished():
	if is_attacking:
		if $AnimatedSprite.animation == "idle":
			$AnimatedSprite.play("attack_ready")
		if $AnimatedSprite.animation == "attack_ready":
			$AnimatedSprite.play("attack_slam")
			emit_signal("zombie_attack")
			$SlamSound.playing = true
			print("ZOMBIE_ATTACK")
		elif $AnimatedSprite.animation == "attack_slam": 
			$AnimatedSprite.play("idle")
			$SlamSound.playing = false
		
			
func _on_SlamSound_finished():
	$SlamSound.playing = false
	
	
func _on_car_explode(): 
	is_dead = true
	var bloodsplat = Bloodsplat.instance()
	bloodsplat.suppress_sound()
	get_parent().add_child(bloodsplat)
	bloodsplat.position = position

	var car_position = player_car.global_position
	bloodsplat.rotation = (global_position - car_position).normalized().angle()
	
	yield(get_tree().create_timer(zombie_death_time), "timeout")
	queue_free()

