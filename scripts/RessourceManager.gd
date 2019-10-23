extends Node

signal ressource_changed(ressource_name, value)
signal island_restored()
signal artefact_discovered(block)
signal all_pandas_fled()

export var ressources = {
	"artefacts" : 0,
	"artefacts_max" : 0,
	"population" : 0
}

var level = 0
var steps_taken = 0
var ressources_gathered = 0
var time = 0

func reset():
	set_ressource("population", 0)
	set_ressource("artefacts", 0)
	set_ressource("artefacts_max", 0)
	steps_taken = 0
	ressources_gathered = 0
	time = 0
	

func add_ressource(ressource_name, value):
	set_ressource(ressource_name, ressources[ressource_name] + value)
	
func set_ressource(ressource_name, value, emit_signals=true):
	ressources[ressource_name] = value
	emit_signal("ressource_changed", ressource_name, value)
	if emit_signals:
		# TODO 
		if false and ressource_name == "artefacts" and has_ressource("artefacts", ressources.artefacts_max): 
			emit_signal("island_restored")
		if ressource_name == "population" and !has_ressource("population", 1):
			emit_signal("all_pandas_fled")
	
func has_ressource(ressource_name, value):
	return ressources[ressource_name] >= value

func _ready():
	# initially fire all ressource change signals
	for ressource_name in ressources:
		set_ressource(ressource_name, ressources[ressource_name], false)
	
	var g = {"level":1}
	if !Engine.editor_hint:
		g = load("res://scripts/NonToolFix.gd").new().g()
	level = g.level
		
func _process(delta):
	time += delta
		