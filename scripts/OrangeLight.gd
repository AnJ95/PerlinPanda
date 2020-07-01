extends Light2D

var weatherManager
func _ready():
	var weatherManager = get_tree().get_nodes_in_group("weather_manager")
	if weatherManager.size() > 0: self.weatherManager = weatherManager[0]
	
func _process(_delta:float):
	energy = 0.8 * (1 - clamp(weatherManager.day.now(), 0, 1))
