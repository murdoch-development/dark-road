extends RigidBody2D

export var acceleration_factor = 300.0
export var turn_factor = 1.0
export var sideways_friction = 0.3

var acceleration_input = 0
var steering_input = 0
var rotation_angle = 0


func _ready():
	pass

func _physics_process(delta):
	get_inputs()
	apply_steering(delta)
	apply_engine_force(delta)
	kill_orthogonal_velocity(delta)

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
	var engine_force_vector = Vector2(0, -1).rotated(rotation) * acceleration_input * acceleration_factor
	apply_central_impulse(engine_force_vector * delta)
	
func apply_steering(delta):
	rotation_angle -= steering_input * turn_factor * delta
	rotation = rotation_angle

func kill_orthogonal_velocity(delta):
	var forward_direction = transform.y.normalized()
	var forward_velocity = forward_direction * forward_direction.dot(linear_velocity)
	var sideways_velocity = linear_velocity - forward_velocity
	var sideways_friction_force = sideways_friction * sideways_velocity.length_squared() * -sideways_velocity.normalized()
	apply_central_impulse(sideways_friction_force * delta)
