extends Node2D

var is_started = false
var button_speed = 500
var is_modulating = false
var modulation = 1.0
var is_moving = false

func _ready():
	$Black.visible = true
	$Bright.visible = false
	$Normal.visible = false
	$PlayButton.visible = true

func _process(delta):
	if Input.is_action_pressed("ui_select")\
	or Input.is_action_pressed("ui_accept"):
		start()
	if is_modulating and modulation >= 0:
		modulation -= delta / 2
		$SlayButton.modulate = Color(1, 1, 1, modulation)
	if is_moving and $LogoROADARK.position.y < 176:
		$LogoROADARK.position.y += delta * button_speed

func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
	   start()

func start():
	if is_started:
		return
	is_started = true
	$PlayButton.visible = false
	$SlayButton.visible = true
	$TitleTrackROADARK.playing = true
	is_modulating = true
	yield(get_tree().create_timer(9.5), "timeout")
	$Black.visible = false
	$Bright.visible = true
	yield(get_tree().create_timer(0.5), "timeout")
	$Bright.visible = false
	$Normal.visible = true
	yield(get_tree().create_timer(7), "timeout")
	is_moving = true
