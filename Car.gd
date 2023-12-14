extends RigidBody2D


var collision_shape: CapsuleShape2D
export var wheel_base: float
export var car_heading: float
export var car_steering_angle: float

export var car_location: Vector2

export var car_speed: float
export var gear: int
export var acellerator: float

export var front_wheel: Vector2
export var rear_wheel: Vector2


var frame_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape = $CollisionShape2D.shape as CapsuleShape2D
	wheel_base = collision_shape.height - (collision_shape.height / 10)
	car_heading = 0
	car_steering_angle = 0
	car_location = Vector2(0, 0)
	car_speed = 0
	gear = 0
	acellerator = 0
	front_wheel = Vector2(0, 0)
	rear_wheel = Vector2(0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if acellerator > 10:
		acellerator = 10
	elif acellerator > 0:
		acellerator -= 0.1	
	if acellerator < 0:
		acellerator = 0
	
	car_steering_angle = 0
	
	if Input.is_action_pressed("ui_right"):
		car_steering_angle = deg2rad(0.5)
	elif Input.is_action_pressed("ui_left"):
		car_steering_angle = deg2rad(-0.5)

	if Input.is_action_pressed("ui_up"):
		acellerator += 0.2
	if Input.is_action_pressed("ui_down"):
		acellerator = 0
	
	if gear == 0:
		car_speed = 0
	else:
		car_speed = gear * 20 * acellerator

	rear_wheel += car_speed * delta * Vector2(cos(car_heading), sin(car_heading))
	front_wheel += car_speed * delta * Vector2(cos(car_heading + car_steering_angle), sin(car_heading + car_steering_angle))

	car_location = (front_wheel + rear_wheel) / 2
	car_heading = atan2(front_wheel.y - rear_wheel.y, front_wheel.x - rear_wheel.x)

	

	position = car_location
	rotation = car_heading
	
	if frame_count % 10 == 0:
			log_to_debug()
	frame_count += 1	


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

func log_to_debug():
	print("Car Heading: ", rad2deg(car_heading))
	print("Car Steering Angle: ", rad2deg(car_steering_angle))
	print("Car Speed: ", car_speed)
	print("Gear: ", gear)
	print("Acellerator: ", acellerator)
	print("Front Wheel: ", front_wheel)
	print("Rear Wheel: ", rear_wheel)
	print("Car Location: ", car_location)
	print("Wheel Base: ", wheel_base)
	print("")

