extends Node2D

signal explode

func _ready():
	pass # Replace with function body

func _on_Car_die():
	var explosion_pos = $Car.position

	var explosion = load("res://Explosion.tscn").instance()
	$Car.death_effect()
	$Car.add_child(explosion)
	yield(get_tree().create_timer(2.2), "timeout")
	# yield(get_tree().create_timer(1), "timeout")
	emit_signal("explode")
	$Car/Sprite.visible = false
	yield(get_tree().create_timer(2), "timeout")
	emit_signal("car_die")

func _on_Car_die_other():
	var explosion_pos = $Car.position
	yield(get_tree().create_timer(2), "timeout")
	var explosion = load("res://Explosion2.tscn").instance()

	$Car.death_effect()
	$Car.add_child(explosion)

	yield(get_tree().create_timer(1), "timeout")
	$Car.visible = false
	yield(get_tree().create_timer(2), "timeout")
	emit_signal("car_die")
