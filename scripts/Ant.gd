extends "Gatherer.gd"

var hill

const SPEED = 18
var frame_time = 0.15
var time_left = frame_time
var angle = 0.0
var target_pos = null
    
func prep(map, cell_pos, hill, nth):
    self.hill = hill
    position = map.calc_px_pos_on_tile(cell_pos)
    .init(map, nth)
    return self
    
func inventory_emptied(_res_name, value): # TODO DELME
    var pos = map.calc_closest_tile_from(position)
    if map.blocks.has(pos) and map.blocks[pos].get_class() == "BlockBugHill":
        for _i in range(0, value):
            map.blocks[pos].upgrade()

 
func _process(delta: float) -> void:
    # Sprite Animation
    time_left -= delta
    if time_left <= 0:
        time_left += frame_time
        $Sprite.frame = ($Sprite.frame + 1) % $Sprite.vframes
    
    # gather and build, prevent walking if so
    if gather_and_build(delta, 1.0):
        return

    # Determine next target if none
    if target_pos == null:
        target_pos = get_next_target()
    
    # Check if current target in vicinity
    if move_towards_then(target_pos, SPEED, delta):
        if map.blocks.has(target_pos):
            var block = map.blocks[target_pos]
            if block.ressource_name_or_null() == "bamboo" and (block.stock > 0 or block.is_infinite_ressource()):
                start_working_on_ressource(block)
            if map.blocks.has(target_pos) and map.blocks[target_pos].get_class() == "BlockBugHill" and inventory.has("bamboo", 1):
                for _i in range(0, inventory.get("bamboo")):
                    hill.upgrade()
                queue_free()
                hill.bug_has_died() # causes a respawn later
        target_pos = null
        
func get_next_target():
    var cell_pos = map.calc_closest_tile_from(position)
    var valid = []
    var bamboo = []
    var home = null
    
    for adjacent in map.get_adjacent_tiles(cell_pos):
        if map.landscapes.has(adjacent) and (!map.blocks.has(adjacent) or map.blocks[adjacent].is_passable()):
            valid.append(adjacent)
        if map.blocks.has(adjacent):
            var block = map.blocks[adjacent]
            if block.get_class() == "BlockBugHill" and inventory.has("bamboo", 1):
                home = adjacent
            if block.ressource_name_or_null() == "bamboo" and (block.stock > 0 or block.is_infinite_ressource()):
                bamboo.append(adjacent)
    
    var target
    if home != null and inventory.has("bamboo", 1):
        target = home
    else:
        if bamboo.size() > 0 and !inventory.has("bamboo", 1): # DECISION: target bamboo only when inv empty?
            target = bamboo[randi()%bamboo.size()]
        else:
            if valid.size() > 0:
                target = valid[randi()%valid.size()]
            else:
                target = cell_pos
    
    var dir = map.calc_px_pos_on_tile(target) - position
    angle = (360) * dir.angle() / (2*PI) + 90
    
    return target

func start_working_on_ressource(ressource):
    working_on_ressource = true
    job_on = ressource
    job_time_left = 4 * ressource.ressource_work_time()
    
    get_node("Particles_" + ressource.ressource_name_or_null()).emitting = true
    
func stepped_on(panda):
    hill.bug_has_died()
    if panda != null:
        inventory.move_to_other(panda.inventory)
    
    var particle = nth.ParticlesBugStomped.instance()
    particle.position = position
    hill.get_bug_holder().add_child(particle)
    particle.emitting = true
    
    queue_free()

func get_sprite_angle():
    return angle
func get_sprite_wiggle_amp_freq():
    return [4, 8]
    
func can_gather():
    return true
func gatherable_ressources():
    return ["bamboo", "leaves"]
func can_build():
    return false
