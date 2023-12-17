extends Node2D
var Bloodsplat = preload("Bloodsplat.tscn")
onready var current_rot = 0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var bloodsplat = Bloodsplat.instance()
	add_child(bloodsplat)
	bloodsplat.rotation = current_rot
	current_rot += delta


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
