extends Node
const distance_between_polarizers = 2
var polarizers = []
var waves = []
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
	
	for wave in waves:
		wave.queue_free()
	waves.clear()
	
	var positions = []
	var angles = []
	
	for polarizer in polarizers:
		positions.append(polarizer.position)
		angles.append(polarizer.angle)
		
	positions.append(analyzer.position)
	
	for i in range(4):
		var new_wave = create_wave(laser.position, positions[0], (PI/2)*i)
		add_child(new_wave)
		
	if polarizers.size() > 0:
		var amplitude = 1
		var angle = angles[0]
		for i in range(positions.size()-1):
			var amplitude_ratio = abs(cos(abs(angles[i] - angle)))
			
			if amplitude_ratio <= 0.01:
				break
			
			var new_wave = create_wave(positions[i], positions[i+1], angles[i], amplitude*amplitude_ratio)
			add_child(new_wave)
			
			amplitude *= amplitude_ratio
			angle = angles[i]


func create_wave(start, end, angle, amplitude=1):
	var wave = wave_scene.instantiate()
	waves.append(wave)
	
	wave.rotate(Vector3(1, 0, 0), angle)
	wave.position = (start+end)/2
	wave.get_active_material(0).set_shader_parameter("scale", amplitude)
	
	return wave


func add_polarizer():
	var new_polarizer = polarizer_scene.instantiate()
	new_polarizer.setup((polarizers.size()+1)*distance_between_polarizers, 0, self)
	
	polarizers.append(new_polarizer)
	add_child(new_polarizer)
	
	var new_dial = dial_scene.instantiate()
	new_dial.attach_polarizer(new_polarizer)
	
	ui.add_child(new_dial)
	
	var analyzer_node = get_node("Analyzer")
	analyzer_node.position.x += distance_between_polarizers
	
	update_laser_path()
