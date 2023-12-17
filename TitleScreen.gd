extends Node2D
signal next_level
signal play_next_song

var is_started = false
var button_speed = 500
var slay_is_modulating = false
var slay_modulation = 1.0
var bright_lights_is_modulating = false
var bright_lights_modulation = 1
var is_moving = false
var skip_level = false

func _ready():
	$Black.visible = true
	$BrightLights.visible = false
	$NormalLights.visible = false
	$SlayButton.visible = false
	$CarPlain.visible = false
	$CarLights.visible = false
	$PlayButton.visible = true
	$CarText.visible = false

func _process(delta):
	if skip_level:
		return
	if Input.is_action_pressed("ui_select")\
	or Input.is_action_pressed("ui_accept"):
		start()
	if slay_is_modulating and slay_modulation >= 0:
		slay_modulation -= delta / 2
		$SlayButton.modulate = Color(1, 1, 1, slay_modulation)
		$Description.modulate = Color(1, 1, 1, slay_modulation)
	if bright_lights_is_modulating and bright_lights_modulation >= 0:
		bright_lights_modulation -= delta / 2
		$BrightLights.modulate = Color(1, 1, 1, bright_lights_modulation)
		print("light: ", bright_lights_modulation)
	if is_moving and $LogoROADARK.position.y < 0:
		$LogoROADARK.position.y += delta * button_speed
	if Input.is_action_pressed("ui_cancel") and not skip_level:
		skip_level = true
		if not is_started:
			emit_signal("play_next_song")
		emit_signal("next_level")

func _on_Area2D_input_event(viewport, event, shape_idx):
	if skip_level:
		return
	if Input.is_action_just_pressed("click"):
	   start()

func start():
	if skip_level:
		return
	if is_started:
		return
	is_started = true
	emit_signal("play_next_song")
	$PlayButton.visible = false
	$SlayButton.visible = true
	slay_is_modulating = true
	yield(get_tree().create_timer(9.5), "timeout")
	$Black.visible = false
	$BrightLights.visible = true
	$NormalLights.visible = true
	bright_lights_is_modulating = true
	$CarLights.visible = true
	yield(get_tree().create_timer(7.5), "timeout")
	$LogoROADARK.visible = true
	is_moving = true
	yield(get_tree().create_timer(5), "timeout")
	emit_signal("next_level")
	
