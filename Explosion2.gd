extends Node2D

func _ready():
	$AnimatedSprite.visible = true
	$AnimatedSprite.playing = true
	$AudioStreamPlayer2D.playing = true
	yield(get_tree().create_timer(1), "timeout")
	visible = false
