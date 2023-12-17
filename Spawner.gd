extends YSort

var player = null
var spawn_radius = 2400
var despawn_distance = 1.5 * spawn_radius
export var max_zombies = 150

var has_started = false

func _ready():
	pass
	# This code was moved to _on_Car_start

func _process(_delta):
	if not has_started: 
		return
	for child in get_children():
		if child.get_script() != null and child.get_script().get_path() == "res://Zombie.gd" and child.position.distance_to(player.position) > despawn_distance:
			remove_child(child)
			child.queue_free()

func spawn():
	if get_child_count() > max_zombies:
		return
	var enemy = load("res://Zombie.tscn").instance()
	add_child(enemy)
	if(player.linear_velocity.length() > 1500):
		var angle = rand_range(-PI/2, PI/2) + player.linear_velocity.normalized().angle() - PI/2
		enemy.position = player.position + Vector2(spawn_radius, 0).rotated(angle)
	if(player.linear_velocity.length() > 500):
		var angle = rand_range(-PI/1.5, PI/1.5) + player.linear_velocity.normalized().angle() - PI/2
		enemy.position = player.position + Vector2(spawn_radius, 0).rotated(angle)
	else:
		var angle = rand_range(0, 2 * PI)
		enemy.position = player.position + Vector2(spawn_radius, 0).rotated(angle)


func _on_Car_start():
	player = get_parent().get_node("Car")
	var timer = Timer.new()
	timer.wait_time = 0.05 # Set this to the desired spawn interval
	timer.one_shot = false
	timer.connect("timeout", self, "spawn")
	add_child(timer)
	timer.start()
	has_started = true
