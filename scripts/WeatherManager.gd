extends CanvasLayer

onready var Cycle = preload("res://scripts/WeatherCycle.gd")

# CONSTS
const DAY_CYCLE_TIME = 120
const TIDE_MIN_LEVEL = 5.5
const TIDE_MAX_LEVEL = 4.5

var weather_time = 30.0

onready var modifier = get_parent().get_node("Map").level_def.weather

onready var day = Cycle.new().init(DAY_CYCLE_TIME, (3/2.0)*PI, [0, 1], 0, modifier.day)
onready var tide = Cycle.new().init(50, 0, [TIDE_MAX_LEVEL, TIDE_MIN_LEVEL], 0, modifier.tide)
onready var rain = Cycle.new().init(180, PI, [0, 1], 0, modifier.rain)
onready var storm = Cycle.new().init(180, PI, [0, 1], 1, modifier.storm)
onready var fog = Cycle.new().init(150, PI, [-1, 1], 1, modifier.fog)

onready var cycles = [day, tide, rain, storm, fog]

const PROB_TO_LIGHTNING_WHEN_TILE_SELECTED = 8.0

const lightning_time_per_tile = 50.0
var time_to_next_lightning = 0

onready var Lightning = preload("res://scenes/Lightning.tscn")

export var day_time_modulate:Gradient

onready var rainNode = $Center/Rain
onready var cloudNode = $Center/Clouds
onready var stormCloudNode = $Center/StormClouds
onready var fogNode = $Center/Fog

var cam
func _ready():
	cam = get_tree().get_nodes_in_group("camera")[0]
	
	
	
var delme = 0
func _process(delta):

	weather_time += delta
	
	for cycle in cycles:
		cycle.set_time(weather_time)
		
	if int(weather_time/5) != int((weather_time - delta) / 5):
		p("########")
		p("day:    " + str(day.now()))
		p("tide:   " + str(tide.now()))
		p("rain:   " + str(rain.now()))
		p("storm:  " + str(storm.now()))
		p("fog:    " + str(fog.now()))
	
	mod(day_time_modulate.interpolate(fmod(weather_time, DAY_CYCLE_TIME) / float(DAY_CYCLE_TIME)))
	
	
	process_storm(delta)
	process_rain()
	process_fog()

func is_storming():
	return storm.now() > 0.6
func process_storm(delta):
	set_particle_amount(stormCloudNode, y(is_storming(), interpol(0.6, 1.0, storm.now(), 10, 20), 0))
	process_lightning(delta)

func is_raining():
	return rain.now() > 0.6
	
func process_rain():
	set_particle_amount(cloudNode, y(is_raining(), interpol(0.6, 1.0, rain.now(), 10, 20), 0))
	set_particle_amount(rainNode, y(is_raining(), interpol(0.6, 1.0, rain.now(), 5, 80), 0))

func process_lightning(delta):
	if !is_storming():
		return
		
	# wait for time to run up and randomness to do its thing
	time_to_next_lightning -= delta
	if time_to_next_lightning > 0:
		return
	var map = get_parent().get_node("Map")
	time_to_next_lightning += lightning_time_per_tile / float(map.landscapes.size())
	
	if randi()%100 > PROB_TO_LIGHTNING_WHEN_TILE_SELECTED * storm.now():
		return

	var cells = map.map_landscape.get_used_cells()
	var id
	var strike = false
	var iterations = 0
	while !strike and iterations < 100:
		id = randi() % cells.size()
		if map.blocks.has(cells[id]):
			if randi()%100 < map.blocks[cells[id]].get_prob_lightning_strike():
				strike = true
		else:
			if randi()%100 < map.landscapes[cells[id]].get_prob_lightning_strike():
				strike = true
		iterations += 1
	if strike:
		var lightning = Lightning.instance().init(map, cells[id])
		map.get_node("Navigation2D/PandaHolder").add_child(lightning)


func process_fog():
	var vp = get_viewport().get_visible_rect().size
	
	var param_offset = Vector2(cam.offset.x, -cam.offset.y) / vp
	var param_scale = cam.zoom.x
	param_offset += Vector2(-0.5 * param_scale, -0.5 * param_scale)
	
	fogNode.material.set_shader_param("intensity", max(fog.now(), 0))
	fogNode.material.set_shader_param("offset", param_offset)
	fogNode.material.set_shader_param("scale", param_scale)
	
func add_fog_pos(pos:Vector2):
	if fogNode == null:
		$Center/Fog.add_fog_pos(pos)
	else:
		fogNode.add_fog_pos(pos)

var particle_duplicates = {}
const particle_min_delta = 5
const particles_max = 80
func set_particle_amount(particle:Particles2D, amount:int):
	
	if !particle_duplicates.has(particle):
		# add 1
		particle_duplicates[particle] = [particle]
		particle.amount = particle_min_delta
		# add n-1
		for _p in range(0, particles_max, particle_min_delta):
			var dupl = particle.duplicate()
			particle_duplicates[particle].append(dupl)
			$Center.add_child(dupl)
	
	for p in range(0, particle_duplicates[particle].size()):
		var dupl = particle_duplicates[particle][p]
		dupl.emitting = amount >= (p+1) * particle_min_delta
					
func mod(col:Color):
	get_parent().get_node("Modulate").color = col
	

####################################
func interpol(minIn, maxIn, nowIn, minOut, maxOut):
	var t = (nowIn - minIn) / float(maxIn - minIn)
	t = max(min(t, 1.0), 0.0)
	return float(minOut) + t * float(maxOut-minOut)
	
static func y(c, a, b):
	if c:
		return a
	else:
		return b
		
func p(obj):
	if get_parent().get_node("Map").print_weather:
		print("## Weather ## " + str(obj))