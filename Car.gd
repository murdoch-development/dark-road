extends RigidBody2D

var Skidmark = preload("Skidmark.tscn")

export var acceleration_factor = 600.0
export var turn_factor = 1.0
export var slow_turn_factor = 0.5
export var very_slow_turn_factor = 0.5
export var drift_turn_factor = 2.0
export var opposite_drift_turn_factor = 0.9
export var sideways_dynamic_friction = 0.3
export var sideways_static_friction = 0.3
export var handbrake_turn_factor = 2.5

var acceleration_input = 0
var steering_input = 0
var rotation_angle = 0
var is_drifting = false
var slow_turning_speed = 100
var very_slow_turning_speed = 50
var no_turning_speed = 10
var min_sideways_speed_for_drift = 150
var dir = 0
var handbrake = false


func _ready():
	pass

func _physics_process(delta):
	print(linear_damp)
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
	elif Input.is_action_pressed("ui_down"):
		acceleration_input = -0.5
	else:
		acceleration_input = 0
		
	handbrake = false
	if Input.is_action_pressed("ui_select"):
		handbrake = true

func apply_engine_force(delta):
	linear_damp = 0
	if handbrake:
		linear_damp = 2
		return
	var engine_force_vector = Vector2.UP.rotated(rotation) * acceleration_input * acceleration_factor
	apply_central_impulse(engine_force_vector * delta)
	
func apply_steering(delta):
	var current_turn_factor = turn_factor

	var forward_direction = Vector2.UP.rotated(rotation)
	var forward_velocity = forward_direction * forward_direction.dot(linear_velocity)

	dir = forward_direction.dot(forward_velocity.normalized())
	if forward_velocity.length() < no_turning_speed:
		rotation = rotation_angle
		return
	if dir > 0:
		if forward_velocity.length() < slow_turning_speed and ! is_drifting:
			current_turn_factor = slow_turn_factor
		if forward_velocity.length() < very_slow_turning_speed:
				current_turn_factor = very_slow_turn_factor
		if is_drifting:
			current_turn_factor = drift_turn_factor
		if handbrake:
			current_turn_factor *= 2
		rotation_angle -= steering_input * current_turn_factor * delta
		if is_drifting and sideways_velocity_direction(rotation_angle) != steering_input:
			#opposite drift
			current_turn_factor = opposite_drift_turn_factor
			rotation_angle += steering_input * current_turn_factor * delta
	elif dir < 0:
		current_turn_factor = drift_turn_factor
		if is_drifting:
			current_turn_factor = 2 * drift_turn_factor
		if handbrake:
			current_turn_factor *= 2
		rotation_angle -= steering_input * current_turn_factor * delta
		
	rotation = rotation_angle

func apply_drift(delta):
	var forward_direction = Vector2.UP.rotated(rotation)
	var forward_velocity = forward_direction * forward_direction.dot(linear_velocity)
	var sideways_velocity = linear_velocity - forward_velocity
	var sideways_friction = sideways_dynamic_friction
	if sideways_velocity.length() >= 100 or (handbrake and linear_velocity.length() > very_slow_turning_speed) :
		is_drifting = true
		if not $TyreSqueal.playing:
			$TyreSqueal.play()
		do_skidmark(forward_velocity)
	else:
		is_drifting = false
		sideways_friction *= 1
		$TyreSqueal.stop()
	var sideways_friction_force = sideways_friction * 10 * sideways_velocity.length() * -sideways_velocity.normalized()
	if not handbrake:
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

	if linear_velocity.length() < no_turning_speed:
		return
		
	var skidmark = Skidmark.instance()
	
	if forward_velocity.length() > 150:
		skidmark.lengthen()
	
	skidmark.rotation = rotation
	if handbrake:
		var second_skidmark = Skidmark.instance()
		second_skidmark.rotation = rotation
		if forward_velocity.length() > 150:
			second_skidmark.lengthen()
		skidmark.position = $BackTyres.global_position
		skidmark.position.y += 8 #Magic Number, dunno why this needs to be done but fixes some weird offset 
		get_parent().add_child(skidmark)
		second_skidmark.position = $FrontTyres.global_position
		second_skidmark.position.y += 8 #Magic Number, dunno why this needs to be done but fixes some weird offset 
		get_parent().add_child(second_skidmark)
	else:
		if dir > 0:
			skidmark.position = $BackTyres.global_position
			skidmark.position.y += 8 #Magic Number, dunno why this needs to be done but fixes some weird offset 
		else:
			skidmark.position = $FrontTyres.global_position
			skidmark.position.y += 8 #Magic Number, dunno why this needs to be done but fixes some weird offset 
		get_parent().add_child(skidmark)
