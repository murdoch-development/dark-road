extends Node2D

export var rotation_speed = 1000.0  # Adjust this to apply larger/smaller rotational force
export var max_rotation_speed = 50.0
export var thrust = 1000.0
export var forward_friction = 0.1  # Replace water_friction with forward_friction
export var sideways_friction = 0.3  # New variable, adjust as needed
export var max_friction = 1000
export var max_speed = 2000.0
export var redirection_factor = 0.01
export var rotation_friction = 500
export var left_button = "ui_left"
export var right_button = "ui_right"

export var expected_top_speed = 80

var starting_thrust

func _process(delta):
	pass

func _ready():
	starting_thrust = thrust
	pass

func _physics_process(delta):

	var velocity = $Physics.linear_velocity
	
	# Calculate the forward and sideways components of the velocity
	var forward_direction = $Physics.transform.y.normalized()
	var forward_velocity = forward_direction * forward_direction.dot(velocity)
	var sideways_velocity = velocity - forward_velocity

	var sideways_speed_ratio = sideways_velocity.length() / max_speed  # Calculate sideways speed ratio

	var rotation_speed_ratio = abs($Physics.angular_velocity) / max_rotation_speed

	# Calculate effective rotation speed based on current rotation speed
	var effective_rotation_speed = lerp(rotation_speed, 0, rotation_speed_ratio)

	if Input.is_action_pressed(right_button):
		$Physics.apply_torque_impulse(effective_rotation_speed)
	elif Input.is_action_pressed(left_button):
		$Physics.apply_torque_impulse(-effective_rotation_speed)

	# Always move forward
	var speed_ratio = velocity.length() / max_speed
	var applied_thrust = lerp(thrust, 0, speed_ratio)  # Decrease thrust as speed approaches max_speed
	$Physics.apply_central_impulse($Physics.transform.y * -applied_thrust * delta)
	
	# Apply forward and sideways friction
	var forward_friction_force = min(forward_friction * forward_velocity.length_squared(), max_friction) * -forward_velocity.normalized()
	var sideways_friction_force = sideways_friction * sideways_velocity.length_squared() * -sideways_velocity.normalized()
	$Physics.apply_central_impulse((forward_friction_force + sideways_friction_force) * delta)
