extends Node

signal ressource_changed(ressource_name, value)

export var ressources = {
	"bamboo": 20,
	"stone": 20,
	"leaves": 20,
	"population": 0
}

func add_ressource(ressource_name, value):
	set_ressource(ressource_name, ressources[ressource_name] + value)
	
func set_ressource(ressource_name, value):
	ressources[ressource_name] = value
	emit_signal("ressource_changed", ressource_name, value)
	
func has_ressource(ressource_name, value):
	return ressources[ressource_name] >= value

func _ready():
	# initially fire all ressource change signals
	for ressource_name in ressources:
		set_ressource(ressource_name, ressources[ressource_name])