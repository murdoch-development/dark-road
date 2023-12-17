extends Label

onready var timer = 480
var start = false
var win = false

func _ready():
	text = str(timer)

func _process(delta):
	if Input.is_action_pressed("ui_up"):
		start = true
	if start == true:
		timer -= delta
		text = str(round(timer))
		if timer <= 0 and not win:
			win = true
			get_parent().get_parent().emit_signal("win")
	
