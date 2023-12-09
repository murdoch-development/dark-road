extends Sprite

var angular_speed = PI
var speed = 0
var gear = 0
var acellerator = 0

func _process(delta):
	var direction = 0

	if Input.is_action_pressed("ui_right"):
		direction += 1
	if Input.is_action_pressed("ui_left"):
		direction -= 1
	if Input.is_action_pressed("ui_up"):
		acellerator += 0.2
		if acellerator > 10:
			acellerator = 10
	elif acellerator > 0:
		acellerator -= 0.3
		if acellerator < 0:
			acellerator = 0
	if Input.is_action_pressed("ui_down"):
		acellerator = 0
	
	# accelerator should decay
	rotation += angular_speed * direction * delta
	
	var velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta
	print("speed: ", speed)
	print("gear: ", gear)
	print("acellerator: ", acellerator)
	if gear == 0:
		speed = 0
		angular_speed = 0
	else:
		speed = gear * 20 * acellerator
		angular_speed = PI

	# if at the edfe of the screen then bounce the car back
	if position.x > get_viewport_rect().size.x:
		position.x = 0
	elif position.x < 0:
		position.x = get_viewport_rect().size.x


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SHIFT:
			gear += 1
		if event.pressed and event.scancode == KEY_SPACE:
			gear -= 1
		
		if gear > 5:
			gear = 5
		if gear <= -1:
			gear = -1
		
