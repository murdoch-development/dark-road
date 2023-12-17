extends Sprite

onready var car = get_parent().get_parent().get_node("Car")
onready var max_fuel = car.max_fuel_tank

var needle: Sprite
var current_fuel
var start_rotation

func _ready():
	needle = $Needle
	start_rotation = needle.rotation

func _process(_delta):
	update_fuel(car.current_fuel_tank)

func update_fuel(fuel: float):
	current_fuel = fuel
	var angle = (current_fuel / max_fuel) * PI
	if start_rotation + angle < start_rotation:
			needle.rotation = start_rotation
	else:
			needle.rotation = start_rotation + angle
