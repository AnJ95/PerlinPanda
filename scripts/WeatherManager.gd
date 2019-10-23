extends CanvasLayer

var weather_time = 40.0

# SEA LEVEL
const TIDE_MIN_LEVEL = 5.5
const TIDE_MAX_LEVEL = 4.5
const TIDE_CYCLE_TIME = 50

# DAY CYCLE
const DAY_CYCLE_TIME = 120.0

# RAIN CYCLE
const RAIN_CYCLE_TIME = 180.0

const PROB_TO_LIGHTNING_WHEN_TILE_SELECTED = 20.0

var sea_level = 0
var day_time = 0.0
var day_level = 0.0
var day_bonus = 0.0
var rain_level = 0
var storm_level = 0.0

const lightning_time_per_tile = 50.0
var time_to_next_lightning = 0

onready var Lightning = preload("res://scenes/Lightning.tscn")

export var day_time_modulate:Gradient

onready var rain = $Center/Rain
onready var clouds = $Center/Clouds
onready var stormClouds = $Center/StormClouds

func _process(delta:float):
	weather_time += delta
	
	# Calculate current states and boni
	var s = sin(weather_time * 2.0*PI / TIDE_CYCLE_TIME)
	sea_level = TIDE_MAX_LEVEL + (TIDE_MIN_LEVEL-TIDE_MAX_LEVEL) * ((s + 1) / 2.0)
	day_time = fmod(weather_time, DAY_CYCLE_TIME)
	day_bonus = -cos(2*PI * weather_time / DAY_CYCLE_TIME)
	day_level = (day_bonus+1) / 2.0
	rain_level = (sin(-2*PI * weather_time / RAIN_CYCLE_TIME) + 1) / 2.0
	storm_level = rain_level * rain_level
	
	#rain_level = 1
	#storm_level = 1
	
	mod(day_time_modulate.interpolate(day_time / float(DAY_CYCLE_TIME)))
	
	process_storm(delta, storm_level)
	process_rain(delta, rain_level)

func is_storming():
	return storm_level > 0.6
func process_storm(delta, storm_level):
	set_particle_amount(stormClouds, y(is_storming(), interpol(0.6, 1.0, storm_level, 10, 20), 0))
	process_lightning(delta, storm_level)

func is_raining():
	return rain_level > 0.6
func process_rain(_delta, rain_level):
	set_particle_amount(clouds, y(is_raining(), interpol(0.6, 1.0, rain_level, 10, 20), 0))
	set_particle_amount(rain, y(is_raining(), interpol(0.6, 1.0, rain_level, 5, 80), 0))

func process_lightning(delta, storm_level):
	if !is_storming():
		return
		
	# wait for time to run up and randomness to do its thing
	time_to_next_lightning -= delta
	if time_to_next_lightning > 0:
		return
	var map = get_parent().get_node("Map")
	time_to_next_lightning += lightning_time_per_tile / float(map.landscapes.size())
	
	if randi()%100 > PROB_TO_LIGHTNING_WHEN_TILE_SELECTED * storm_level:
		return
	
	var l = map.map_landscape
	var lightning = Lightning.instance().init(map, l.get_used_cells()[randi() % l.get_used_cells().size()])
	map.get_node("Navigation2D/PandaHolder").add_child(lightning)

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
	
func get_sea_level():
	return sea_level
	
func get_rain_level():
	return rain_level
	
func get_day_time():
	return day_time

func get_day_bonus():
	return day_bonus
	
	
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