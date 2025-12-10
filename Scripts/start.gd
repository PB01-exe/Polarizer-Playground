extends Control
var simulator

# Called when the node enters the scene tree for the first time.
func _ready():
	simulator = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	simulator.switch_scene()
