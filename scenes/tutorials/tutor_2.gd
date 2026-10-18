extends Main

const TUTORCONSTRUCTIONS = [
	preload("uid://c0rrybc5bgfno"),
	preload("uid://nmq3klwu0rtw"),
]

func _ready() -> void:
	current = self
	
	gold_label.text = "Gold: " + str(gold)
	
	var hb = HOMEBASE.instantiate()
	@warning_ignore("integer_division")
	hb.grid_pos = WORLD_SIZE / 2
	entity_root.add_child(hb)
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			surface_tile_map_layer.set_cell(p, 1, Vector2i(0, 0))
	
	var tree = TREE.instantiate()
	tree.grid_pos = (WORLD_SIZE / 2) + Vector2i(-4, -1)
	entity_root.add_child(tree)
	
	var bush = BUSH.instantiate()
	bush.grid_pos = (WORLD_SIZE / 2) + Vector2i(-1, -3)
	entity_root.add_child(bush)
	
	var crystal = CRYSTAL.instantiate()
	crystal.grid_pos = (WORLD_SIZE / 2) + Vector2i(5, 3)
	entity_root.add_child(crystal)

	camera_2d.position = Vector2(WORLD_SIZE) * GridMetric.GRID_PX * 0.5
	camera_2d.limit_left = 0
	camera_2d.limit_top = 0
	camera_2d.limit_right = int(WORLD_SIZE.x * GridMetric.GRID_PX.x)
	camera_2d.limit_bottom = int(WORLD_SIZE.y * GridMetric.GRID_PX.y)
	
	hotbar.add_hotbar_item(ERASE_ICON)
	for c in TUTORCONSTRUCTIONS:
		hotbar.add_hotbar_item(c)

func _process(delta: float) -> void:	
	super(delta) 
	if gold >= 25:
		SceneGirl.change_scene("res://scenes/end_scene/end_scene.tscn")
