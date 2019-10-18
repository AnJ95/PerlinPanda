extends CanvasLayer

var weather_time = 0.0

# SEA LEVEL
const TIDE_MIN_LEVEL = 5.5
const TIDE_MAX_LEVEL = 4.5
const TIDE_CYCLE_TIME = 50

# DAY CYCLE
const DAY_CYCLE_TIME = 120

# RAIN CYCLE
const RAIN_CYCLE_TIME = 30

const PROB_TO_LIGHTNING_WHEN_TILE_SELECTED = 50

var sea_level = 0
var day_time = 0.0
var day_bonus = 0.0
var rain_level = 0
var storm_level = 0.0

const lightning_time_per_tile = 20.0
var time_to_next_lightning = 0

var Lightning = preload("res://scenes/lightning.tscn")

export var day_time_modulate:Gradient

func _process(delta:float):
	weather_time += delta
	
	var s = sin(weather_time * 2.0*PI / TIDE_CYCLE_TIME)
	sea_level = TIDE_MAX_LEVEL + (TIDE_MIN_LEVEL-TIDE_MAX_LEVEL) * ((s + 1) / 2.0)
	
	day_time += delta
	if day_time >= DAY_CYCLE_TIME:
		day_time -= DAY_CYCLE_TIME
	day_bonus = -cos(2*PI * day_time / float(DAY_CYCLE_TIME))
	rain_level = (sin(-weather_time * 2.0*PI / RAIN_CYCLE_TIME) + 1) / 2.0

	storm_level = rain_level * rain_level
	
	rain_level = 1
	storm_level = 1

	time_to_next_lightning -= delta
	if time_to_next_lightning <= 0:
		var map = get_parent().get_node("Map")
		time_to_next_lightning += lightning_time_per_tile / float(map.landscapes.size())
		if randi()%100 <= PROB_TO_LIGHTNING_WHEN_TILE_SELECTED * map.weather.storm_level:
			var l = map.map_landscape
			var lightning = Lightning.instance().init(map, l.get_used_cells()[randi() % l.get_used_cells().size()])
			map.get_node("Navigation2D/ParticleHolder").add_child(lightning)
	
	
	mod(day_time_modulate.interpolate(day_time / float(DAY_CYCLE_TIME)))
	#var g = 0.5 + (day_bonus + 1) * 0.5
	#get_parent().get_node("ParallaxBackground/ParallaxLayer/Node2D").modulate = Color(g,g,g,1)
	
	if storm_level > 0.6:
		var new_amount = storm_level * 20
		if new_amount > $Center/StormClouds.amount + 2:
			$Center/StormClouds.amount = new_amount
			
		$Center/StormClouds.emitting = true
	else:
		$Center/StormClouds.emitting = false
		
	if rain_level > 0.6:
		var new_amount = (rain_level-0.5) * 24 + 2
		if abs(new_amount - $Center/Clouds.amount) + 2:
			$Center/Clouds.amount = new_amount
		new_amount = ((rain_level-0.6)/0.4) * 60
		if abs(new_amount - $Center/Rain.amount) + 5:
			$Center/Rain.amount = new_amount
			
		$Center/Clouds.emitting = true
		$Center/Rain.emitting = true
	else:
		$Center/Clouds.emitting = false
		$Center/Rain.emitting = false
	
func mod(col):
	get_parent().get_node("Modulate").color = col
	
func get_sea_level():
	return sea_level
	
func get_rain_level():
	return rain_level
	
func get_day_time():
	return day_time

func get_day_bonus():
	return day_bonus