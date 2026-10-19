extends Main

const TUTORCONSTRUCTIONS = [
	preload("uid://c0rrybc5bgfno"),
]

func _ready() -> void:
	current = self
	
	gold_label.text = "Gold: " + str(gold)
	
	var ob = OBJECTIVE.instantiate()
	@warning_ignore("integer_division")
	ob.grid_pos = (WORLD_SIZE / 2) + Vector2i(4, 0)
	ob.need = preload("res://systems/crafting/items/log.tres")
	ob.is_tutorial = true
	entity_root.add_child(ob)
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			surface_tile_map_layer.set_cell(p, 1, Vector2i(0, 0))
	
	var tree = TREE.instantiate()
	tree.grid_pos = (WORLD_SIZE / 2) + Vector2i(0, -1)
	entity_root.add_child(tree)
	
	var loc = HOUSE.instantiate()
	loc.grid_pos = (WORLD_SIZE / 2) + Vector2i(-5, -1)
	entity_root.add_child(loc)

	camera_2d.position = Vector2(WORLD_SIZE) * GridMetric.GRID_PX * 0.5
	camera_2d.limit_left = 0
	camera_2d.limit_top = 0
	camera_2d.limit_right = int(WORLD_SIZE.x * GridMetric.GRID_PX.x)
	camera_2d.limit_bottom = int(WORLD_SIZE.y * GridMetric.GRID_PX.y)
	
	hotbar.add_hotbar_item(ERASE_ICON)
	for c in TUTORCONSTRUCTIONS:
		hotbar.add_hotbar_item(c)
