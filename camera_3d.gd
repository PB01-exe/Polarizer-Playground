extends Camera3D
const sensitivity = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("D"):
		position.x += sign(position.z)*sensitivity
	if Input.is_action_pressed("A"):
		position.x -= sign(position.z)*sensitivity
		
func _input(event):
	if event.is_action_pressed("Ctrl"):
		position.z *= -1
		rotation.y = PI-rotation.y
