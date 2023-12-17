extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var initial_light_energy = $rearlight.energy
onready var initial_bulb_energy = $rear_bulb_right.energy

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("ui_select"):
		$rear_bulb_right.energy = 4
		$rear_bulb_left.energy = 4
		$rearlight.energy = 1
		$rearlight.scale.x = 2
		$rearlight.scale.y = 2
	else:
		$rear_bulb_right.energy = initial_bulb_energy
		$rear_bulb_left.energy = initial_bulb_energy
		$rearlight.energy = initial_light_energy
		$rearlight.scale.x = 1
		$rearlight.scale.y = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
