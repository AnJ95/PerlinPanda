extends Node

signal ressource_changed(ressource_name, value)
signal island_restored()
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

var unlocked_buyables_at_level_start = []

var g

func reset():
	set_ressource("population", 0, false)
	set_ressource("artefacts", 0, false)
	set_ressource("artefacts_max", 0, false)
	steps_taken = 0
	ressources_gathered = 0
	time = 0

func add_ressource(ressource_name, value, emit_signals=true):
	set_ressource(ressource_name, ressources[ressource_name] + value, emit_signals)
	
func set_ressource(ressource_name, value, emit_signals=true):
	ressources[ressource_name] = value
	emit_signal("ressource_changed", ressource_name, value)
	if emit_signals:
		if ressource_name == "population" and !has_ressource("population", 1):
			# reset unlocked buyables
			g.unlocked_buyables = unlocked_buyables_at_level_start
			emit_signal("all_pandas_fled")
			

func on_artefact_selected(buyable):
	add_ressource("artefacts", 1)
	
	# add to global
	var g = load("res://scripts/NonToolFix.gd").new().g()
	# dont add duplicate
	if g.unlocked_buyables.find(buyable.locked_id) == -1:
		g.unlocked_buyables.append(buyable.locked_id)
	
	if has_ressource("artefacts", ressources.artefacts_max): 
		emit_signal("island_restored")
			
func has_ressource(ressource_name, value):
	return ressources[ressource_name] >= value

func _ready():
	# initially fire all ressource change signals
	for ressource_name in ressources:
		set_ressource(ressource_name, ressources[ressource_name], false)
	
	g = load("res://scripts/NonToolFix.gd").new().g()
	level = g.level
	
	# save unlocked buyables, in case player loses, and they have to be reset
	unlocked_buyables_at_level_start = []
	for locked_id in g.unlocked_buyables:
		unlocked_buyables_at_level_start.append(locked_id)
		
func _process(delta):
	time += delta
		