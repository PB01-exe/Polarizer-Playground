extends Node
const distance_between_polarizers = 2
var polarizer_tracker = 0
var polarizers = []
var dials = []
var waves = []
var intensity
var polarizer_scene
var dial_scene
var wave_scene
var laser
var analyzer
var polarizer_ui
var output_label
var analysis_label
var percent_label

# Called when the node enters the scene tree for the first time.
func _ready():
	polarizer_scene = load("res://Scenes/polarizer.tscn")
	dial_scene = load("res://Scenes/angle_control.tscn")
	wave_scene = load("res://Scenes/wave.tscn")
	laser = get_node("Laser")
	analyzer = get_node("Analyzer")
	polarizer_ui = get_node("UI/PolarizerControls/Panel/Margin/VBox")
	output_label = get_node("UI/IntensityControls/InfoPanel/OutputValue")
	analysis_label = get_node("UI/IntensityControls/InfoPanel/AnalysisValue")
	percent_label = get_node("UI/IntensityControls/InfoPanel/PercentValue")
	
	set_output(10)
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
			
			if amplitude_ratio <= 0.05:
				break
			
			var new_wave = create_wave(positions[i], positions[i+1], angles[i], amplitude*amplitude_ratio)
			add_child(new_wave)
			
			amplitude *= amplitude_ratio
			angle = angles[i]
	
	set_output()


func create_wave(start, end, angle, amplitude=1):
	var wave = wave_scene.instantiate()
	waves.append(wave)
	
	wave.rotate(Vector3(1, 0, 0), angle)
	wave.position = (start+end)/2
	wave.get_active_material(0).set_shader_parameter("scale", amplitude)
	
	return wave


func add_polarizer():
	
	if (polarizers.size() < 5):
		polarizer_tracker += 1
		
		var new_polarizer = polarizer_scene.instantiate()
		new_polarizer.setup((polarizers.size()+1)*distance_between_polarizers+laser.position.x, 0, self)
		
		polarizers.append(new_polarizer)
		add_child(new_polarizer)
		
		var new_dial = dial_scene.instantiate()
		new_dial.attach_polarizer(new_polarizer)
		new_dial.set_number(polarizer_tracker)
		
		dials.append(new_dial)
		polarizer_ui.add_child(new_dial)
		
		analyzer.position.x += distance_between_polarizers
		
		update_laser_path()


func remove_polarizer():
	
	if (polarizers.size() > 0):
		polarizer_tracker -= 1
		
		var polarizer_to_remove = polarizers[-1]
		polarizers.pop_back()
		polarizer_to_remove.queue_free()
		
		var dial_to_remove = dials[-1]
		dials.pop_back()
		dial_to_remove.queue_free()
		
		analyzer.position.x -= distance_between_polarizers
		
		update_laser_path()


func set_output(value=intensity):
	intensity = value
	output_label.text = str(value)
	
	var final_intensity = intensity
	
	if (polarizers.size() > 0):
		var angle = polarizers[0].angle
		for i in range(polarizers.size()):
			var new_angle = polarizers[i].angle
			final_intensity *= (abs(cos(abs(new_angle - angle))))**2
			angle = new_angle
	
	analysis_label.text = str((round(final_intensity*100))/100)
	percent_label.text = str(round((final_intensity/intensity)*100))


func _on_output_slider_value_changed(value):
	set_output(value)
