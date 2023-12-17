extends Node2D
signal die

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	return
	yield(get_tree().create_timer(1), "timeout")
	emit_signal("die")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
