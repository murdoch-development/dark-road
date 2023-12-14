extends Node2D

export var acceleration_factor = 30.0
export var turn_factor = 3.5

var acceleration_input = 0
var steering_input = 0
var rotation_angle = 0

func _ready():
	pass

func _physics_process(delta):
	$Physics.apply_central_force(1,1)
