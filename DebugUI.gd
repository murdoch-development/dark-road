extends Control

# Assuming the labels are direct children of a GridContainer which is a child of DebugUI
# var vehicle_properties = {
#     "wheel_base": 70,  # Distance from front to rear wheel
#     "steering_angle": 15,  # Amount that front wheel turns, in degrees
#     "steer_angle": 0,
#     "velocity": Vector2.ZERO,  # Current velocity of the vehicle
#     "engine_rpm": 0,  # Current engine RPM
#     "max_rpm": 6000,  # Maximum RPM
#     "acceleration": Vector2.ZERO,  # Current acceleration
#     "braking": -450,  # Braking value
#     "max_speed_reverse": 250,  # Maximum speed in reverse
#     "friction": -0.9,  # Friction coefficient
#     "drag": -0.0015,  # Drag coefficient
#     "current_gear": 0  # Current gear of the vehicle
# }

var debug_labels = []

func _ready():
	# Find the GridContainer node
	var grid_container = $GridContainer
	
	# Collect the Label nodes from the GridContainer
	for label in grid_container.get_children():
		if label is Label:
			debug_labels.append(label)
	
	# Initialize the labels with default text
	debug_labels[0].text = "Wheel Base: "
	debug_labels[1].text = "Steering Angle: "
	debug_labels[2].text = "Steer Angle: "
	debug_labels[3].text = "Velocity: "
	debug_labels[4].text = "Engine RPM: "
	debug_labels[5].text = "Max RPM: "
	debug_labels[6].text = "Acceleration: "
	debug_labels[7].text = "Braking: "
	debug_labels[8].text = "Max Speed Reverse: "
	debug_labels[9].text = "Friction: "
	debug_labels[10].text = "Drag: "
	debug_labels[11].text = "Current Gear: "
	# Add more initialization as needed

func _process(_delta):
	var car_node = get_parent().get_parent().get_node("CarKinematic")

	# # Update the labels with the current values
	debug_labels[0].text = "Wheel Base: " + str(car_node.wheel_base)
	debug_labels[1].text = "Steering Angle: " + str(car_node.steering_angle)
	debug_labels[2].text = "Steer Angle: " + str(car_node.steer_angle)
	debug_labels[3].text = "Velocity: " + str(car_node.velocity)
	debug_labels[4].text = "Engine RPM: " + str(car_node.engine_rpm)
	debug_labels[5].text = "Max RPM: " + str(car_node.MAX_RPM)
	debug_labels[6].text = "Acceleration: " + str(car_node.acceleration)
	debug_labels[7].text = "Braking: " + str(car_node.braking)
	debug_labels[8].text = "Max Speed Reverse: " + str(car_node.max_speed_reverse)
	debug_labels[9].text = "Friction: " + str(car_node.friction)
	debug_labels[10].text = "Drag: " + str(car_node.drag)
	debug_labels[11].text = "Current Gear: " + str(car_node.current_gear)

	# Add more updates as needed
