extends Panel
var associated_polarizer

# Called when the node enters the scene tree for the first time.
func _ready():
	var label = get_node("Label")
	label.text = "0"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_v_slider_value_changed(value):
	var label = get_node("Label")
	label.text = str(value)
	associated_polarizer.set_angle(deg_to_rad(value))


func attach_polarizer(polarizer):
	associated_polarizer = polarizer
