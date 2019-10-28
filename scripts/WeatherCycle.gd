extends Object

var cycle_time
var offset
var interv
var skip
var modifier

var now = 0

func init(cycle_time, offset=0, interv=[-1,1], skip=0, modifier=0):	
	self.cycle_time = cycle_time
	self.offset = offset
	self.interv = interv
	self.skip = skip
	self.modifier = modifier
	return self

func set_time(weather_time:float):
	var s = sin(weather_time * 2.0*PI / float(cycle_time) + offset)
	#if skip == 0:
	now = interv[0] + (interv[1]-interv[0]) * ((s + 1.0) / 2.0)
	
	now += modifier

func now():
	return now

