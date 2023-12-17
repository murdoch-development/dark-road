extends RigidBody2D
signal screen_shake(is_offroad, speed)

var Skidmark = preload("Skidmark.tscn")

export var acceleration_factor = 600.0
export var turn_factor = 1.0
export var slow_turn_factor = 0.5
export var fast_turn_factor = 0.8
export var very_slow_turn_factor = 0.5
export var drift_turn_factor = 2.0
export var opposite_drift_turn_factor = 0.9
export var sideways_dynamic_friction = 0.3
export var sideways_static_friction = 0.3
export var handbrake_turn_factor = 2.5
export var top_speed = 2800

var high_speed = 2000
var very_high_speed = 2600
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
var is_offroad = false
var bloodmark_duration = 3
var bloodmark_time_left = 0

func _ready():
	$EngineRevving.play()

func _physics_process(delta):
	get_inputs()
	apply_steering(delta)
	apply_engine_force(delta)
	apply_drift(delta)
	rev_engine()
	make_bloodmarks(delta)
	emit_signal("screen_shake", is_offroad, linear_velocity.length())

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
	if is_offroad:
		linear_damp = 1
	var forward_direction = Vector2.UP.rotated(rotation)
	var forward_velocity = forward_direction * forward_direction.dot(linear_velocity)
	if forward_velocity.length() > top_speed and acceleration_input > 0:
		#dont forward accelerate at top speed
		return
	if forward_velocity.length() > top_speed / 2 and acceleration_input < 0:
		#dont reverse accelerate at half top speed
		return
	var current_acceleration_factor = acceleration_factor
	if forward_velocity.length() > high_speed:
		current_acceleration_factor = acceleration_factor / 2
	var engine_force_vector = Vector2.UP.rotated(rotation) * acceleration_input * current_acceleration_factor
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
		if forward_velocity.length() > high_speed and not is_drifting:
			current_turn_factor = fast_turn_factor
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
	
	if (sideways_velocity.length() >= min_sideways_speed_for_drift and forward_velocity.length() < 2000)\
	or (sideways_velocity.length() >= 3 * min_sideways_speed_for_drift and forward_velocity.length() >= 2000)\
	or (handbrake and linear_velocity.length() > very_slow_turning_speed):
		is_drifting = true
		if not $TyreSqueal.playing:
			$TyreSqueal.play()
		do_skidmark_particles(forward_velocity)
	else:
		is_drifting = false
		sideways_friction *= 1
		$TyreSqueal.stop()
		dont_skidmark_particles()
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

func do_skidmark_particles(forward_velocity):
	if linear_velocity.length() < no_turning_speed:
		return
	if handbrake:
		$Tyres/FrontLeft.emitting = true
		$Tyres/FrontRight.emitting = true
		$Tyres/MidLeft.emitting = true
		$Tyres/MidRight.emitting = true
		$Tyres/BackLeft.emitting = true
		$Tyres/BackRight.emitting = true
	elif dir > 0: #going forward
		$Tyres/FrontLeft.emitting = false
		$Tyres/FrontRight.emitting = false
		$Tyres/MidLeft.emitting = true
		$Tyres/MidRight.emitting = true
		$Tyres/BackLeft.emitting = true
		$Tyres/BackRight.emitting = true
	else: #going backward
		$Tyres/FrontLeft.emitting = true
		$Tyres/FrontRight.emitting = true
		$Tyres/MidLeft.emitting = false
		$Tyres/MidRight.emitting = false
		$Tyres/BackLeft.emitting = false
		$Tyres/BackRight.emitting = false

func dont_skidmark_particles():
	$Tyres/FrontLeft.emitting = false
	$Tyres/FrontRight.emitting = false
	$Tyres/MidLeft.emitting = false
	$Tyres/MidRight.emitting = false
	$Tyres/BackLeft.emitting = false
	$Tyres/BackRight.emitting = false


func do_skidmark(forward_velocity):
	
	############ LEGACY CODE BEING SKIPPED BELOW ##############
	return

	if linear_velocity.length() < no_turning_speed:
		return
		
	var back_skidmark = Skidmark.instance()
	var mid_skidmark = Skidmark.instance()
	
	if forward_velocity.length() > 150:
		back_skidmark.lengthen()
		mid_skidmark.lengthen()
	
	back_skidmark.rotation = rotation
	mid_skidmark.rotation = rotation
	if handbrake:
		var front_skidmark = Skidmark.instance()
		front_skidmark.rotation = rotation
		if forward_velocity.length() > 150:
			front_skidmark.lengthen()
		back_skidmark.position = $BackTyres.global_position
		back_skidmark.position.y += 10 #Magic Number, dunno why this needs to be done but fixes some weird offset 
		mid_skidmark.position = $MidTyres.global_position
		mid_skidmark.position.y += 10 #Magic Number, dunno why this needs to be done but fixes some weird offset 
		get_parent().add_child(back_skidmark)
		get_parent().add_child(mid_skidmark)
		front_skidmark.position = $FrontTyres.global_position
		front_skidmark.position.y += 10 #Magic Number, dunno why this needs to be done but fixes some weird offset 
		get_parent().add_child(front_skidmark)
	else:
		if dir > 0:
			back_skidmark.position = $BackTyres.global_position
			back_skidmark.position.y += 10 #Magic Number, dunno why this needs to be done but fixes some weird offset 
			mid_skidmark.position = $MidTyres.global_position
			mid_skidmark.position.y += 10 #Magic Number, dunno why this needs to be done but fixes some weird offset 
			get_parent().add_child(mid_skidmark)
		else:
			back_skidmark.position = $FrontTyres.global_position
			back_skidmark.position.y += 10 #Magic Number, dunno why this needs to be done but fixes some weird offset 
			mid_skidmark.queue_free()
		get_parent().add_child(back_skidmark)

func rev_engine():
	var normalized_speed = min(linear_velocity.length() / top_speed, 1)
	var target_pitch_scale
	var sound_change_rate = 0.01
	if acceleration_input == 1:
		target_pitch_scale = 3
	elif acceleration_input == -0.5:
		target_pitch_scale = 1.5
	else:
		sound_change_rate = 0.1
		target_pitch_scale = 0.6 + 2.4 * normalized_speed
	$EngineRevving.pitch_scale = lerp($EngineRevving.pitch_scale, target_pitch_scale, sound_change_rate)
	
func hit_zombie():
	bloodmark_time_left = bloodmark_duration
	
func make_bloodmarks(delta):
	bloodmark_time_left -= delta
	if bloodmark_time_left > 0:
		$Tyres/BloodFrontLeft.emitting = true
		$Tyres/BloodFrontRight.emitting = true
		$Tyres/BloodMidLeft.emitting = true
		$Tyres/BloodMidRight.emitting = true
		$Tyres/BloodBackLeft.emitting = true
		$Tyres/BloodBackRight.emitting = true
	else:
		$Tyres/BloodFrontLeft.emitting = false
		$Tyres/BloodFrontRight.emitting = false
		$Tyres/BloodMidLeft.emitting = false
		$Tyres/BloodMidRight.emitting = false
		$Tyres/BloodBackLeft.emitting = false
		$Tyres/BloodBackRight.emitting = false



func _on_RoadDetector_body_entered(body):
	is_offroad = false

func _on_RoadDetector_body_exited(body):
	is_offroad = true

