extends Node2D
signal end_credits

export var scroll_speed = 100

var is_scrolling = true

var faded_time = 0
export var faded_time_max = 5

func _ready(): 
	position.y = 1080

func _process(delta):
	if $Title2.get_global_position().y <= 0: 
		is_scrolling = false
	if is_scrolling:
		position.y = position.y - delta*scroll_speed
	else: 
		modulate = Color(1,1,1,1-(faded_time/faded_time_max))
		faded_time += delta
	if faded_time > faded_time_max - 3: 
		emit_signal("end_credits")
	if faded_time > faded_time_max: 
		queue_free()
