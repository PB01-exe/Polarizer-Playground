extends Control
var simulator

# Called when the node enters the scene tree for the first time.
func _ready():
	simulator = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	



func _on_add_polarizer_button_pressed():
	simulator.add_polarizer()


func _on_remove_polarizer_button_pressed():
	simulator.remove_polarizer()

func _on_output_slider_value_changed(value):
	simulator.set_output(value)


func _on_back_button_pressed():
	simulator.switch_scene()
