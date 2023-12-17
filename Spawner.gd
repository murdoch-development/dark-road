extends YSort

var player = null
var spawn_radius = 2400
var despawn_distance = 1.5 * spawn_radius
export var max_zombies = 150

func _ready():
  player = get_parent().get_child(0)
  print(player.position)
  var timer = Timer.new()
  timer.wait_time = 0.05 # Set this to the desired spawn interval
  timer.one_shot = false
  timer.connect("timeout", self, "spawn")
  add_child(timer)
  timer.start()

func _process(_delta):
	for child in get_children():
		if child.get_script() != null and child.get_script().get_path() == "res://Zombie.gd" and child.position.distance_to(player.position) > despawn_distance:
			remove_child(child)
			child.queue_free()

func spawn():
	if get_child_count() > max_zombies:
		return
	var enemy = load("res://Zombie.tscn").instance()
	add_child(enemy)
	var angle = rand_range(-PI/2, PI/2) + player.linear_velocity.normalized().angle()
	enemy.position = player.position + Vector2(spawn_radius, 0).rotated(angle)
