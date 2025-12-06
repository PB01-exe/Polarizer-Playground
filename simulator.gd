extends Node
const distance_between_polarizers = 2
var polarizers = []
var polarizer_scene
var dial_scene
var wave_scene
var laser
var analyzer
var ui

# Called when the node enters the scene tree for the first time.
func _ready():
	polarizer_scene = load("res://polarizer.tscn")
	dial_scene = load("res://dial.tscn")
	wave_scene = load("res://wave.tscn")
	laser = get_node("Laser")
	analyzer = get_node("Analyzer")
	ui = get_node("UI/PolarizerControls")
	
	update_laser_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func update_laser_path():
	var positions = [laser.position]
	for polarizer in polarizers:
		positions.append(polarizer.position)
	positions.append(analyzer.position)
	
	for i in range(positions.size()-1):
		var new_wave = create_wave(positions[i], positions[i+1], 90)
		add_child(new_wave)


func create_wave(start, end, angle):
	var wave = wave_scene.instantiate()
	wave.position = (start+end)/2
	return wave


func _add_polarizer():
	var new_polarizer = polarizer_scene.instantiate()
	new_polarizer.position.x = (polarizers.size()+1)*distance_between_polarizers
	polarizers.append(new_polarizer)
	add_child(new_polarizer)
	
	var new_dial = dial_scene.instantiate()
	new_dial.attach_polarizer(new_polarizer)
	ui.add_child(new_dial)
	
	var analyzer_node = get_node("Analyzer")
	analyzer_node.position.x += distance_between_polarizers
	
	update_laser_path()
