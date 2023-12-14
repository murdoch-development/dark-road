extends KinematicBody2D

var wheel_base = 70  # Distance from front to rear wheel
var steering_angle = 20  # Amount that front wheel turns, in degrees
var steer_angle = 0

var velocity: Vector2 = Vector2.ZERO

var engine_rpm = 0
const MAX_RPM = 6000


var acceleration:Vector2 = Vector2.ZERO

var braking = -450
var max_speed_reverse = 250

var friction = -0.9
var drag = -0.0015

var current_gear = 0
const MAX_GEAR = 5
const MIN_GEAR = -1
var max_speed_per_gear = [80, 120, 160, 200, 240]
var max_speed_revers = 80

func _ready():
    var sprite = $Sprite
    if sprite and sprite.texture:
        wheel_base = sprite.texture.get_size().y * 0.65
    else:
        wheel_base = 70

func _physics_process(delta):
	get_input(delta)

	calculate_velocity(delta)
	calulate_acceleration()
	calcualte_deceleration(delta)
	# apply_friction()


	velocity += acceleration * delta
	velocity = move_and_slide(velocity)


func get_input(delta):
	var turn = 0
	acceleration = Vector2.ZERO
	
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1
	if Input.is_action_pressed("accelerate"):
		engine_rpm = calculate_rpm(engine_rpm, delta, true)
	else:
		engine_rpm = calculate_rpm(engine_rpm, delta, false)
	if Input.is_action_pressed("brake"):
		acceleration = acceleration.normalized() * braking
	
	if Input.is_action_just_pressed("shift_up") and current_gear < MAX_GEAR:
		current_gear += 1
	if Input.is_action_just_pressed("shift_down") and current_gear > MIN_GEAR:
		current_gear -= 1

	if current_gear > MAX_GEAR:
		current_gear = MAX_GEAR
	if current_gear < MIN_GEAR:
		current_gear = MIN_GEAR
	
	steer_angle = turn * deg2rad(steering_angle)

func calculate_velocity(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()

func calulate_acceleration():   
	var max_speed = 0 
	if(current_gear == -1):
		max_speed = max_speed_reverse
	else:
		max_speed = max_speed_per_gear[current_gear - 1]
	
	var gear_acceleration_factor = 1 * (current_gear * 0.1)
	
	acceleration = transform.x * (engine_rpm * gear_acceleration_factor)
	
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	
func calcualte_deceleration(delta):
	if acceleration.length() < 0.1:
		acceleration = Vector2.ZERO
	else:
		acceleration = acceleration.normalized() * acceleration.length() * 1.5 * delta

func calculate_rpm(current_rpm, delta_time, accelerating = true):
	var change_per_second = 3500  # Define the rate of RPM change per second
	var rpm_change = change_per_second * delta_time
	var rpm = 0

	if accelerating:
		if current_rpm + rpm_change < MAX_RPM:
			rpm = current_rpm + rpm_change
		else:
			rpm = MAX_RPM
	else:
		if current_rpm - rpm_change > 0:
			rpm = current_rpm - rpm_change
		else:
			rpm = 0
	return rpm

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	if velocity.length() < 100:
		friction_force *= 3
	acceleration += drag_force + friction_force
