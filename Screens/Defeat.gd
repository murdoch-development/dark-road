extends Node2D

signal restart_level
signal go_to_menu


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RestartButton_pressed():
	emit_signal("restart_level")


func _on_MainMenuButton_pressed():
	emit_signal("go_to_menu")
