extends Node
const distance_between_polarizers = 2
var polarizer_tracker = 0
var start_screen = true
const cam_sensitivity = 0.1
const cam_min_position = 2.5
const cam_max_position = 13.5
var intensity = 10
var polarizers = []
var dials = []
var waves = []
var ui
var start
var polarizer_scene
var dial_scene
var wave_scene
var laser
var analyzer
var camera
var start_camera
var polarizer_ui
var output_label
var analysis_label
var percent_label

# Called when the node enters the scene tree for the first time.
func _ready():
	polarizer_scene = load("res://Scenes/polarizer.tscn")
	dial_scene = load("res://Scenes/angle_control.tscn")
	wave_scene = load("res://Scenes/wave_pair.tscn")
	ui = load("res://Scenes/ui.tscn").instantiate()
	start = load("res://Scenes/start.tscn").instantiate()
	laser = get_node("Laser")
	analyzer = get_node("Analyzer")
	camera = get_node("Camera3D1")
	start_camera = get_node("Camera3D2")

	add_child(start)
	start_camera.make_current()
	
	update_laser_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("D"):
		camera.position.x = clamp(camera.position.x + sign(camera.position.z)*cam_sensitivity, cam_min_position, cam_max_position)
	if Input.is_action_pressed("A"):
		camera.position.x = clamp(camera.position.x - sign(camera.position.z)*cam_sensitivity, cam_min_position, cam_max_position)
	

func update_laser_path():
	
	for i in range(2, waves.size()):
		waves[i].queue_free()
	waves = waves.slice(0, 2)
	
	var positions = []
	var angles = []
	
	for polarizer in polarizers:
		positions.append(polarizer.position)
		angles.append(polarizer.angle)
		
	positions.append(analyzer.position)
	
	for i in range(2):
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
	
	if !start_screen:
		set_output()


func create_wave(start_pos, end_pos, angle, amplitude=1):
	var wave = wave_scene.instantiate()
	waves.append(wave)
	
	wave.rotate(Vector3(1, 0, 0), angle)
	wave.position = (start_pos+end_pos)/2
	
	var wave1 = wave.get_node("Wave1")
	var wave2 = wave.get_node("Wave2")
	
	wave2.set_surface_override_material(0, wave1.get_active_material(0))
	wave1.get_active_material(0).set_shader_parameter("scale", amplitude)
	
	return wave


func add_polarizer():
	
	if (polarizers.size() < 5):
		polarizer_tracker += 1
		
		var new_polarizer = polarizer_scene.instantiate()
		new_polarizer.setup((polarizers.size()+1)*distance_between_polarizers+laser.position.x, 0, self, polarizer_tracker)
		
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
	output_label.text = str(intensity)
	
	var final_intensity = intensity
	
	if (polarizers.size() > 0):
		var angle = polarizers[0].angle
		for i in range(polarizers.size()):
			var new_angle = polarizers[i].angle
			final_intensity *= (abs(cos(abs(new_angle - angle))))**2
			angle = new_angle
	
	analysis_label.text = str((round(final_intensity*100))/100)
	percent_label.text = str(round((final_intensity/intensity)*100))
	

func switch_scene():
	
	if start_screen:
		
		remove_child(start)
		add_child(ui)
		
		polarizer_ui = get_node("UI/PolarizerControls/Panel/Margin/VBox")
		output_label = get_node("UI/IntensityControls/InfoPanel/OutputValue")
		analysis_label = get_node("UI/IntensityControls/InfoPanel/AnalysisValue")
		percent_label = get_node("UI/IntensityControls/InfoPanel/PercentValue")
		
		set_output()
		camera.make_current()
		start_screen = false
		
	else:
		
		remove_child(ui)
		add_child(start)
		
		start_camera.make_current()
		start_screen = true


func _input(event):
	
	if !start_screen:
		
		if event.is_action_pressed("Q"):
			for element in get_node("UI").get_children():
				var center = (get_viewport().size.x - element.size.x)/2
				element.position.x = center + (center - element.position.x)
		
		if event.is_action_pressed("Q"):
			camera.position.z *= -1
			camera.rotation.y = PI-camera.rotation.y
