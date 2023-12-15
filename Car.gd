extends RigidBody2D

var Skidmark = preload("Skidmark.tscn")

export var acceleration_factor = 600.0
export var turn_factor = 1.0
export var drift_turn_factor = 2.0
export var opposite_drift_turn_factor = 0.9
export var sideways_dynamic_friction = 0.3
export var sideways_static_friction = 0.3

var acceleration_input = 0
var steering_input = 0
var rotation_angle = 0
var is_drifting = false


func _ready():
	pass

func _physics_process(delta):
	get_inputs()
	apply_steering(delta)
	apply_engine_force(delta)
	apply_drift(delta)

func get_inputs():
	if Input.is_action_pressed("ui_left"):
		steering_input = 1
	elif Input.is_action_pressed("ui_right"):
		steering_input = -1
	else:
		steering_input = 0
	if Input.is_action_pressed("ui_up"):
		acceleration_input = 1
	else:
		acceleration_input = 0

func apply_engine_force(delta):
	var engine_force_vector = Vector2.UP.rotated(rotation) * acceleration_input * acceleration_factor
	apply_central_impulse(engine_force_vector * delta)
	
func apply_steering(delta):
	var current_turn_factor = turn_factor
	if is_drifting:
		current_turn_factor = drift_turn_factor

	var forward_direction = Vector2.UP.rotated(rotation)
	var forward_velocity = forward_direction * forward_direction.dot(linear_velocity)
	if forward_velocity.length() < 50 and ! is_drifting:
		current_turn_factor *= 0.5
	rotation_angle -= steering_input * current_turn_factor * delta
	if is_drifting:
		if sideways_velocity_direction(rotation_angle) != steering_input:
			#opposite drift
			rotation_angle += steering_input * current_turn_factor * delta * opposite_drift_turn_factor
	rotation = rotation_angle

func apply_drift(delta):
	var forward_direction = Vector2.UP.rotated(rotation)
	var forward_velocity = forward_direction * forward_direction.dot(linear_velocity)
	var sideways_velocity = linear_velocity - forward_velocity
	var sideways_friction = sideways_dynamic_friction
	if sideways_velocity.length() < 100:
		is_drifting = false
		sideways_friction *= 1
	else:
		is_drifting = true
		do_skidmark(forward_velocity)
	var sideways_friction_force = sideways_friction * 10 * sideways_velocity.length() * -sideways_velocity.normalized()
	apply_central_impulse(sideways_friction_force * delta)

func sideways_velocity_direction(rotation_angle):
	#RIGHT = -1, LEFT = 1
	var forward_direction = Vector2.UP.rotated(rotation_angle)
	var perpendicular_vector = Vector2(forward_direction.y, -forward_direction.x)

	var sideways_velocity = linear_velocity - (forward_direction * forward_direction.dot(linear_velocity))

	if perpendicular_vector.dot(sideways_velocity) > 0:
		return -1 # Sideways velocity is to the right
	else:
		return 1 # Sideways velocity is to the left

func do_skidmark(forward_velocity):
	var skidmark = Skidmark.instance()
	
	if forward_velocity.length() > 150:
		skidmark.lengthen()
	
	skidmark.rotation = rotation
	skidmark.position = $BackTyres.global_position
	skidmark.position.y += 8 #Magic Number, dunno why this needs to be done but fixes some weird offset 
	get_parent().add_child(skidmark)
