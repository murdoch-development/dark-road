extends KinematicBody2D

var wheel_base = 70
var steering_angle = 15  # You might want to increase this for more pronounced drifts
var engine_power = 800
var friction = -0.9
var drag = -0.001
var braking = -450
var max_speed_reversed = 250
var slip_speed = 100  # Speed at which slipping starts
var very_slip_speed = 400  # Speed at which slipping starts
var traction_fast = 0.01  # Reduced traction to allow for slipping
var traction_med = 0.1
var traction_slow = 0.7  # Normal traction

var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_direction 

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)
	print(velocity.length())

func get_input():
	var turn = 0
	if Input.is_action_pressed("ui_right"):
		turn += 1
	if Input.is_action_pressed("ui_left"):
		turn -= 1
	steer_direction = turn * deg2rad(steering_angle)
	
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * braking

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > very_slip_speed:
		traction = traction_fast
	elif velocity.length() > slip_speed:
		traction = traction_med
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reversed)
	rotation = new_heading.angle()
	
func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force
