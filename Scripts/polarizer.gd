extends Node3D
var angle
var associated_dial
var simulator

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_angle(new_angle):
	angle = new_angle
	simulator.update_laser_path()
	

func setup(position_x, new_angle, simulator_ref, num):
	position.x = position_x
	angle = new_angle
	simulator = simulator_ref
	get_node("computer1/Label3D1").text = str(num)
	get_node("computer2/Label3D2").text = str(num)
