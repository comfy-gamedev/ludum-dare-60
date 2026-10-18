extends Main

const TUTORCONSTRUCTIONS = [
	preload("uid://c0rrybc5bgfno"),
	preload("uid://nmq3klwu0rtw"),
	preload("uid://c7sjwdmihoy6j")
	
	
]

func _ready() -> void:
	current = self
	
	gold_label.text = "Gold: " + str(gold)
	
	var ob = OBJECTIVE.instantiate()
	@warning_ignore("integer_division")
	ob.grid_pos = (WORLD_SIZE / 2) + Vector2i(0, 0)
	ob.need = preload("uid://dcbi7ka0kvgjf")
	entity_root.add_child(ob)
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			surface_tile_map_layer.set_cell(p, 1, Vector2i(0, 0))
	
	var bush = BUSH.instantiate()
	bush.grid_pos = (WORLD_SIZE / 2) + Vector2i(-4, -1)
	entity_root.add_child(bush)
	
	var bush2 = BUSH.instantiate()
	bush2.grid_pos = (WORLD_SIZE / 2) + Vector2i(-1, -3)
	entity_root.add_child(bush2)
	
	var bush3 = BUSH.instantiate()
	bush3.grid_pos = (WORLD_SIZE / 2) + Vector2i(5, 3)
	entity_root.add_child(bush3)

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
