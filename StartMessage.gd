extends Node2D

var timer = 0

func _ready():
	modulate = Color(0,0,0,0)

func _process(delta): 
	if timer < 2:
		timer += delta
	
	
	modulate = Color(1,1,1,max(0, (timer-1)/2))
	
	
func _on_Car_start():
	visible = false
