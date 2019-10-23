extends Node2D

################################################
### INVENTORY
var subscriber = null
var active = false
var inventory = {}
var maximums = {}
const ABS_MAX = 99

var show_max = false
var show_if_0 = false

func init(subscriber, active, start_inventory, max_inventory):
	self.subscriber = subscriber
	self.active = active
	self.inventory = start_inventory
	self.maximums = max_inventory
	update_view()
	return self

func clone():
	var dupl = duplicate()
	dupl.inventory = {"bamboo":0, "stone":0, "leaves":0}
	dupl.maximums = {"bamboo":ABS_MAX, "stone":ABS_MAX, "leaves":ABS_MAX}
	for res in inventory:
		dupl.inventory[res] = inventory[res]
	for res in maximums:
		dupl.maximums[res] = maximums[res]
	return dupl
		
func get_max(ressource):
	if maximums.has(ressource):
		return min(maximums[ressource], ABS_MAX)
	return ABS_MAX
	
func has(ressource, amount):
	if amount == 0:
		return true
	if !inventory.has(ressource):
		return false
	return inventory[ressource] >= amount
	
func try_get(ressource, amount):
	if !inventory.has(ressource):
		return 0
	return min(inventory[ressource], amount)
	
func try_take(ressource, amount):
	var actual_amount = try_get(ressource, amount)
	add(ressource, -actual_amount)
	return actual_amount
	
func set(ressource, amount):
	amount = max(amount, 0)
	amount = min(amount, get_max(ressource))
	inventory[ressource] = amount
	update_view()

func add(ressource, add):
	var amount = get(ressource) + add
	amount = max(amount, 0)
	amount = min(amount, get_max(ressource))
	set(ressource, amount)
	if add > 0:
		if subscriber != null:
			subscriber.notify_inventory_increase(ressource, add)
	
func get(ressource):
	if !inventory.has(ressource):
		return 0
	return inventory[ressource]

func get_free(ressource):
	return get_max(ressource) - get(ressource)
	
func update_view():
	visible = active
	if !active:
		return
		
	var num_visible = 0
	for res in ["bamboo", "stone", "leaves"]:
		var val = 0
		if has(res, 1):
			val = get(res)
		if val > 0 or (show_if_0 and get_max(res) > 0):
			num_visible += 1

		var node = $FollowLayer.get_node("Inventory_" + res)
		node.show_max_value = show_max
		node.max_value = get_max(res)
		node.visible = val > 0 or (show_if_0 and get_max(res) > 0)
			
		node.rect_position.y = - (num_visible-1)*30
	
		node.value = val
		node.update()
		
func move_to_other(other_inventory):
	for res in inventory:
		var has = try_get(res, ABS_MAX)
		var can_get = other_inventory.get_max(res) - other_inventory.get(res)
		other_inventory.add(res, try_take(res, min(has, can_get)))
		
func _to_string():
	return "Inventory(" + str(inventory) + " / " + str(maximums) + ")"