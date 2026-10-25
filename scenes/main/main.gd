extends Node2D
class_name Main

const TICK_RATE = 8.0
const PAN_SPEED = 16.0 * 10.0
const WORLD_SIZE = Vector2i(128, 128)
const CYCLE_END = 8*40
const OBJECTIVE_GOAL = 1

const META_REGISTERED_PARTS = &"Main__registered_parts"
const META_BUILD_BLOCKED_SIGN = &"Main__build_blocked_sign"

const ERASE_ICON = preload("uid://r63jdvojly4a")
const BUILD_BLOCKED_ICON = preload("uid://d31q2nuro1kt8")


const HOUSE = preload("uid://6gtvs4ggkcwd")
const PIT = preload("uid://btc2onty6jr4i")
const HOMEBASE = preload("uid://xgk4sw8nurj8")
const OBJECTIVE = preload("uid://kc23kghe407a")

const BUSH = preload("uid://fohd4r7tj11x")
const CRYSTAL = preload("uid://bb3usincgqjfp")
const ROCK = preload("uid://cpag0rr03s5qo")
const TREE = preload("uid://bayold7n6brg0")
const WATER = preload("uid://ceiw0p6112gmu")

const BREAD = preload("uid://d0nrky4wbersl")

const RESOURCES = [BUSH, ROCK, TREE, WATER, BUSH, ROCK, TREE, CRYSTAL]

const CONSTRUCTIONS = [
	preload("uid://c0rrybc5bgfno"),
	preload("uid://nmq3klwu0rtw"),
	preload("uid://cdj1pydrhinj6"),
	preload("uid://dn7sbmuuobqsx"),
	preload("uid://bv0d35xti4rip"),
	#preload("uid://dihg3y5nmbf5i"),#pedestal :(
	#preload("uid://bfkgt3wvanaqj"),
	preload("uid://c7sjwdmihoy6j"),
	preload("uid://c85aj58cwtkhk"),
	preload("uid://bsrvcnwyvw8pi"),
	preload("uid://cniaep2ikgsjy"),
	preload("uid://b16w8jlme64hc"),
]

const BASE_TILE_SOURCE = 1
const PATH_TILE_SOURCE = 2
const FASTPATH_TILE_SOURCE = 3

static var current: Main

enum TileType {
	INVALID,
	NOTHING,
	PATH,
	BUILDING,
}

@onready var surface_tile_map_layer: TileMapLayer = $SurfaceTileMapLayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var hotbar: HBoxContainer = $UICanvasLayer/Hotbar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var entity_root: Node2D = $EntityRoot
@onready var preview_root: Node2D = $PreviewRoot

@onready var gold_label: Label = $UICanvasLayer/GoldLabel
@onready var day_label: RichTextLabel = $UICanvasLayer/DayLabel

@onready var recipe_map_panel: RecipeMap = $UICanvasLayer/RecipeMapPanel
@onready var night_panel: VBoxContainer = $UICanvasLayer/NightPanel
@onready var auto_check_button: CheckButton = $UICanvasLayer/NightPanel/AutoCheckButton
@onready var go_button: Button = $UICanvasLayer/NightPanel/GoButton

var building_parts: Dictionary[Vector2i, RegisteredBuildingPart]

var tick_entities: Dictionary[Node, bool] # HashSet
var pedestals: Array[BaseBuilding] = []

var gold: int = 15:
	set(val):
		gold = val
		if is_node_ready():
			gold_label.text = "Gold: " + str(val)

var day_count: int = 0:
	set(val):
		day_count = val
		if day_count <= 20:
			day_label.text = "Day: [color=GOLD]" + str(day_count) + "[/color]"
		elif day_count <= 40:
			day_label.text = "Day: [color=SILVER]" + str(day_count) + "[/color]"
		elif day_count <= 80:
			day_label.text = "Day: [color=PERU]" + str(day_count) + "[/color]"
		else:
			day_label.text = "Day: [color=BROWN]" + str(day_count) + "[/color]"

var _ticking: bool = true
var _t: float = 0.0
var _tick_t: int = 0

var _tool_preview: Node2D
var _tool_rot: int = 0

var _objective: BaseBuilding

var _queued_load_save_data: PackedByteArray

## Used for mouse enter/exit signals
var _mouse_building: BaseBuilding

func _ready() -> void:
	current = self
	
	gold_label.text = "Gold: " + str(gold)
	MusicMan.cue_music("hops")
	
	camera_2d.position = Vector2(WORLD_SIZE) * GridMetric.GRID_PX * 0.5
	camera_2d.limit_left = 0
	camera_2d.limit_top = 0
	camera_2d.limit_right = int(WORLD_SIZE.x * GridMetric.GRID_PX.x)
	camera_2d.limit_bottom = int(WORLD_SIZE.y * GridMetric.GRID_PX.y)
	
	hotbar.add_hotbar_item(ERASE_ICON)
	for c in CONSTRUCTIONS:
		hotbar.add_hotbar_item(c)
	
	if _queued_load_save_data:
		_load_save()
		_do_night()
		return
	
	var hb = HOMEBASE.instantiate()
	@warning_ignore("integer_division")
	hb.grid_pos = WORLD_SIZE / 2
	entity_root.add_child(hb)
	
	var ob = OBJECTIVE.instantiate()
	@warning_ignore("integer_division")
	ob.grid_pos = (WORLD_SIZE / 2) + Vector2i(6, 0)
	if Globals.is_easy:
		ob.need = BREAD
	entity_root.add_child(ob)
	_objective = ob
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			surface_tile_map_layer.set_cell(p, 1, Vector2i(randi() % 2, randi() % 2))
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			if randi_range(0, 25) == 0 and get_tile_type(p) == TileType.NOTHING:
				var skip = false
				for d in GridMetric.DIRS:
					if get_tile_type(p + d) != TileType.NOTHING:
						if randi_range(0, 4) != 0:
							skip = true
				if skip:
					continue
				var tree = RESOURCES.pick_random().instantiate()
				tree.grid_pos = p
				entity_root.add_child(tree)


func _process(delta: float) -> void:
	var pan = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	if pan:
		camera_2d.position += pan * PAN_SPEED * delta / camera_2d.zoom
		camera_2d.offset = camera_2d.position.snappedf(1.0 / camera_2d.zoom.x) - camera_2d.position
		# sync pos within limits
		(func ():
			camera_2d.position = camera_2d.position.clamp(Vector2(camera_2d.limit_left, camera_2d.limit_top), Vector2(camera_2d.limit_right, camera_2d.limit_bottom))
		).call_deferred()
	
	if _ticking:
		_t += delta
		var tick_sec = 1.0 / TICK_RATE
		while _t > tick_sec:
			_t -= tick_sec
			_tick()
			_tick_t += 1
			if _tick_t > CYCLE_END:
				_tick_t = 0
				_t = 0.0
				_do_night()
				day_count += 1
				break


func _tick() -> void:
	for ent: Node in tick_entities.keys():
		if is_instance_valid(ent) and not ent.is_queued_for_deletion():
			ent.tick(_tick_t)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_toggle"):
		camera_2d.zoom = Vector2(0.5, 0.5) if camera_2d.zoom == Vector2.ONE else Vector2.ONE
		camera_2d.offset = camera_2d.position.snappedf(1.0 / camera_2d.zoom.x) - camera_2d.position
	
	elif event.is_action_pressed("toggle_compendium"):
		recipe_map_panel.visible = not recipe_map_panel.visible
	
	elif event.is_action_pressed("recenter") and _ticking:
		camera_2d.position = Vector2(WORLD_SIZE) * GridMetric.GRID_PX * 0.5
	
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var gp: Vector2i = Vector2i((get_viewport().canvas_transform.affine_inverse() * event.position / GridMetric.GRID_PX).floor())
			_do_tool(gp, hotbar.get_data(hotbar.selected))
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_tool_rot = posmod(_tool_rot + 1, 4)
			_refresh_preview()
	
	elif event is InputEventMouseMotion:
		var gp: Vector2i = Vector2i((get_viewport().canvas_transform.affine_inverse() * event.position / GridMetric.GRID_PX).floor())
		if _tool_preview:
			preview_root.position = (get_global_mouse_position() / GridMetric.GRID_PX).floor() * GridMetric.GRID_PX
			if _tool_preview is BaseBuilding:
				_check_tool_building_overlap()
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var data = hotbar.get_data(hotbar.selected)
			if data is not ConstructionInfo or data.mode != ConstructionInfo.Mode.BUILDING:
				_do_tool(gp, data)
		
		# Building mouse enter/exit
		
		if not is_instance_valid(_mouse_building):
			_mouse_building = null
		var new_mouse_building_part = get_building_part(gp)
		var new_mouse_building = new_mouse_building_part.building if new_mouse_building_part else null
		if new_mouse_building != _mouse_building:
			if _mouse_building:
				_mouse_building.mouse_exited.emit()
			_mouse_building = new_mouse_building
			if _mouse_building:
				_mouse_building.mouse_entered.emit()
	
	elif OS.is_debug_build() and event.is_action_pressed("debug_goto_night") and _ticking:
		_tick_t = CYCLE_END
	
	elif OS.is_debug_build() and event.is_action_pressed("debug_give_gold"):
		gold += 500
	
	elif OS.is_debug_build() and event.is_action_pressed("debug_win"):
		var it = ItemInstance.new()
		it.item = _objective.need
		_objective.place_item(_objective.grid_pos, it)
	

func _start_tickin() -> void:
	_ticking = true
	go_button.hide()


func _check_auto_dawn() -> void:
	if auto_check_button.button_pressed:
		_do_dawn()
	else:
		go_button.show()


func _do_night() -> void:
	_ticking = false
	animation_player.play("night")
	MusicMan.event("Nightstart1")
	MusicMan.cue_music("troubles")
	night_panel.show()
	go_button.hide()
	auto_check_button.show()


func _do_dawn() -> void:
	animation_player.play("dawn")
	MusicMan.event("Nightstart1")
	if (day_count + 1) % 4 == 0:
		MusicMan.cue_music("dragon")
	else:
		MusicMan.cue_music("hops")
	go_button.hide()
	if !auto_check_button.button_pressed:
		auto_check_button.hide()
	
	if not _objective.is_tutorial:
		print("== AUTOSAVE ==")
		var save_data = _create_save()
		SaveManager.write_save(SaveManager.SlotKind.AUTOSAVE, 0, save_data)


func load_save(save_data: PackedByteArray) -> void:
	_queued_load_save_data = save_data


func _create_save() -> PackedByteArray:
	var buf := StreamPeerBuffer.new()
	buf.put_u8(int(Globals.is_easy))
	buf.put_u32(day_count)
	buf.put_u32(gold)
	buf.put_u8(_objective.grid_pos.x)
	buf.put_u8(_objective.grid_pos.y)
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			var sid := surface_tile_map_layer.get_cell_source_id(p)
			var coord := surface_tile_map_layer.get_cell_atlas_coords(p)
			buf.put_u8(sid)
			buf.put_u8(coord.x)
			buf.put_u8(coord.y)
	
	var scenes: PackedInt64Array
	
	var ent_buf := StreamPeerBuffer.new()
	
	for e in entity_root.get_children():
		if e == _objective:
			continue
		if e is BaseBuilding:
			var sc_uid = ResourceUID.text_to_id(ResourceUID.path_to_uid(e.scene_file_path))
			var sc_i = scenes.find(sc_uid)
			if sc_i == -1:
				sc_i = scenes.size()
				scenes.append(sc_uid)
			assert(sc_i >= 0 and sc_i <= 255)
			ent_buf.put_u8(sc_i)
			ent_buf.put_u8((e.placement_reason << 4) | posmod(e.grid_rot, 4))
			ent_buf.put_u8(e.grid_pos.x)
			ent_buf.put_u8(e.grid_pos.y)
	
	buf.put_var(scenes)
	buf.put_data(ent_buf.data_array)
	
	return buf.data_array


func _load_save() -> void:
	var buf := StreamPeerBuffer.new()
	buf.data_array = _queued_load_save_data
	_queued_load_save_data = PackedByteArray()
	
	Globals.is_easy = bool(buf.get_u8())
	day_count = buf.get_u32()
	gold = buf.get_u32()
	var ob_x: int = buf.get_u8()
	var ob_y: int = buf.get_u8()
	
	var ob = OBJECTIVE.instantiate()
	if Globals.is_easy:
		ob.need = BREAD
	ob.grid_pos = Vector2i(ob_x, ob_y)
	entity_root.add_child(ob)
	_objective = ob
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			var sid = buf.get_u8()
			var coord_x = buf.get_u8()
			var coord_y = buf.get_u8()
			surface_tile_map_layer.set_cell(p, sid, Vector2i(coord_x, coord_y))
	
	var scene_ids: PackedInt64Array = buf.get_var()
	
	while buf.get_position() < buf.get_size():
		var sc_i = buf.get_u8()
		var reason_and_rot: int = buf.get_u8()
		var reason: BaseBuilding.PlacementReason = (reason_and_rot >> 4) as BaseBuilding.PlacementReason
		var grid_rot: int = (reason_and_rot & 0b1111)
		var grid_pos_x: int = buf.get_u8()
		var grid_pos_y: int = buf.get_u8()
		var scene_file_id: int = scene_ids[sc_i]
		var scene_file: String = ResourceUID.get_id_path(scene_file_id)
		var scene: PackedScene = load(scene_file)
		var building: BaseBuilding = scene.instantiate()
		building.placement_reason = reason
		building.grid_pos = Vector2i(grid_pos_x, grid_pos_y)
		building.grid_rot = grid_rot
		entity_root.add_child(building)


func get_tick() -> int:
	return _tick_t


func get_world_rect() -> Rect2i:
	return Rect2i(Vector2i.ZERO, WORLD_SIZE)


func get_tile_type(grid_pos: Vector2i) -> TileType:
	if not get_world_rect().has_point(grid_pos):
		return TileType.INVALID
	
	if grid_pos in building_parts:
		return TileType.BUILDING
	
	var source = surface_tile_map_layer.get_cell_source_id(grid_pos)
	var coord = surface_tile_map_layer.get_cell_atlas_coords(grid_pos)
	match [source, coord]:
		[PATH_TILE_SOURCE, _]: return TileType.PATH
		[FASTPATH_TILE_SOURCE, _]: return TileType.PATH
	
	return TileType.NOTHING


func building_add_part(building: BaseBuilding, grid_pos: Vector2i, part: int) -> void:
	assert(grid_pos not in building_parts)
	var bp = RegisteredBuildingPart.new()
	bp.building = building
	bp.grid_pos = grid_pos
	bp.part = part
	building_parts[grid_pos] = bp
	var meta: Array = building.get_meta(META_REGISTERED_PARTS, [])
	meta.append([grid_pos, part])
	building.set_meta(META_REGISTERED_PARTS, meta)
	Utils.ensure_connected(building.tree_exiting, building_teardown, CONNECT_APPEND_SOURCE_OBJECT)


func building_remove_part(building: BaseBuilding, grid_pos: Vector2i, part: int) -> void:
	assert(grid_pos in building_parts)
	assert(building_parts[grid_pos].building == building)
	assert(building_parts[grid_pos].part == part)
	building_parts.erase(grid_pos)
	var meta: Array = building.get_meta(META_REGISTERED_PARTS, [])
	meta.erase([grid_pos, part])
	building.set_meta(META_REGISTERED_PARTS, meta)
	if meta.is_empty():
		Utils.ensure_disconnected(building.tree_exiting, building_teardown)


func building_teardown(building: BaseBuilding) -> void:
	for parts in building.get_meta(META_REGISTERED_PARTS).duplicate():
		building_remove_part(building, parts[0], parts[1])


func get_building_part(grid_pos: Vector2i) -> RegisteredBuildingPart:
	return building_parts.get(grid_pos)


func register_tick_entity(ent: Node) -> void:
	assert(ent not in tick_entities)
	tick_entities[ent] = true
	ent.tree_exiting.connect(unregister_tick_entity.bind(ent))


func unregister_tick_entity(ent: Node) -> void:
	assert(ent in tick_entities)
	tick_entities.erase(ent)
	ent.tree_exiting.disconnect(unregister_tick_entity)


func connect_paths(a: Vector2i, b: Vector2i) -> void:
	assert((a-b) in GridMetric.DIRS)
	assert(get_tile_type(a) == TileType.PATH)
	assert(get_tile_type(b) == TileType.PATH)
	
	var nbor_map: Dictionary[int, Vector2i] = {
		0b0000: Vector2i(0, 0),
		0b0001: Vector2i(3, 0),
		0b0010: Vector2i(2, 1),
		0b0011: Vector2i(1, 3),
		0b0100: Vector2i(3, 1),
		0b0101: Vector2i(1, 1),
		0b0110: Vector2i(0, 3),
		0b0111: Vector2i(3, 3),
		0b1000: Vector2i(2, 0),
		0b1001: Vector2i(1, 2),
		0b1010: Vector2i(1, 0),
		0b1011: Vector2i(3, 2),
		0b1100: Vector2i(0, 2),
		0b1101: Vector2i(2, 2),
		0b1110: Vector2i(2, 3),
		0b1111: Vector2i(0, 1),
	}
	if surface_tile_map_layer.get_cell_atlas_coords(b) == Vector2i(0, 0):
		MusicMan.event_oneshot_2d("FrogHop" + str(randi_range(1, 4)), get_viewport(), a * 16)
	var f = func (p: Vector2i, d: Vector2i) -> void:
		var s = surface_tile_map_layer.get_cell_source_id(p)
		var c = surface_tile_map_layer.get_cell_atlas_coords(p)
		var n = nbor_map.find_key(c)
		assert(n != null)
		var r = GridMetric.dir_to_rot(d)
		var nn = n | (1 << r)
		var cc = nbor_map[nn]
		surface_tile_map_layer.set_cell(p, s, cc)
	
	f.call(a, b-a)
	f.call(b, a-b)


func disconnect_paths(a: Vector2i, b: Vector2i) -> void:
	assert((a-b) in GridMetric.DIRS)
	assert(get_tile_type(a) == TileType.PATH)
	
	var nbor_map: Dictionary[int, Vector2i] = {
		0b0000: Vector2i(0, 0),
		0b0001: Vector2i(3, 0),
		0b0010: Vector2i(2, 1),
		0b0011: Vector2i(1, 3),
		0b0100: Vector2i(3, 1),
		0b0101: Vector2i(1, 1),
		0b0110: Vector2i(0, 3),
		0b0111: Vector2i(3, 3),
		0b1000: Vector2i(2, 0),
		0b1001: Vector2i(1, 2),
		0b1010: Vector2i(1, 0),
		0b1011: Vector2i(3, 2),
		0b1100: Vector2i(0, 2),
		0b1101: Vector2i(2, 2),
		0b1110: Vector2i(2, 3),
		0b1111: Vector2i(0, 1),
	}
	
	var p := a
	var d := b-a
	
	var s = surface_tile_map_layer.get_cell_source_id(p)
	var c = surface_tile_map_layer.get_cell_atlas_coords(p)
	var n = nbor_map.find_key(c)
	assert(n != null)
	var r = GridMetric.dir_to_rot(d)
	var nn = n & ~(1 << r)
	var cc = nbor_map[nn]
	surface_tile_map_layer.set_cell(p, s, cc)


func _do_tool(grid_pos: Vector2i, tool: Variant) -> void:
	if tool == ERASE_ICON:
		var bp = get_building_part(grid_pos)
		if bp:
			if bp.building.placement_reason == BaseBuilding.PlacementReason.PLAYER:
				if bp.building is PedestalBuilding:
					pedestals.erase(bp.building)
				if bp.building.get("item"):
					if bp.building.item.sprite:
						bp.building.item.sprite.queue_free()
				if bp.building.get("items"):
					for i in bp.building.items:
						if i and i.sprite:
							i.sprite.queue_free()
				if bp.building.get("result"):
					if bp.building.result.sprite:
						bp.building.result.sprite.queue_free()
				bp.building.get_parent().remove_child(bp.building)
				bp.building.queue_free()
				gold += bp.building.info.gold_cost
		else:
			if get_world_rect().has_point(grid_pos) and get_tile_type(grid_pos) != TileType.NOTHING:
				match surface_tile_map_layer.get_cell_source_id(grid_pos):
					2: gold += preload("uid://c0rrybc5bgfno").gold_cost
					3: gold += preload("uid://dn7sbmuuobqsx").gold_cost
				surface_tile_map_layer.set_cell(grid_pos, BASE_TILE_SOURCE, Vector2i(0, 0))
				for d in GridMetric.DIRS:
					if get_tile_type(grid_pos + d) == TileType.PATH:
						disconnect_paths(grid_pos + d, grid_pos)
		
		# TODO: fixup neighbor tiles (make paths become unfinished again)
	
	elif tool is ConstructionInfo:
		match tool.mode:
			ConstructionInfo.Mode.TILE:
				if gold < tool.gold_cost:
					return
				
				if get_tile_type(grid_pos) == TileType.NOTHING:
					surface_tile_map_layer.set_cell(grid_pos, tool.tileset_source_id, tool.tileset_atlas_coord)
					gold -= tool.gold_cost
				elif get_tile_type(grid_pos) == TileType.PATH:
					var esid = surface_tile_map_layer.get_cell_source_id(grid_pos)
					if esid != tool.tileset_source_id:
						match esid:
							2: gold += preload("uid://c0rrybc5bgfno").gold_cost
							3: gold += preload("uid://dn7sbmuuobqsx").gold_cost
						surface_tile_map_layer.set_cell(grid_pos, tool.tileset_source_id, surface_tile_map_layer.get_cell_atlas_coords(grid_pos))
						gold -= tool.gold_cost
			
			ConstructionInfo.Mode.BUILDING:
				
				# check placement
				
				if _check_tool_building_overlap():
					return
				
				# check costs
				
				if gold < tool.gold_cost:
					return
				
				var paid_item: bool = true
				
				if tool.item_req:
					paid_item = false
					if pedestals.is_empty():
						return
					var ped = pedestals[pedestals.find(func(p): return p.item and p.item.item == tool.item_req)]
					if ped.item.sprite:
						ped.item.sprite.queue_free()
					ped.item = null
					paid_item = true
				
				if not paid_item:
					return
				
				# execute build
				
				var b : BaseBuilding = tool.building_scene.instantiate()
				
				gold -= tool.gold_cost
				
				if b is PedestalBuilding:
					pedestals.append(b)
				b.placement_reason = BaseBuilding.PlacementReason.PLAYER
				b.grid_pos = grid_pos
				b.info = tool
				if tool.building_can_rotate:
					b.grid_rot = _tool_rot
				entity_root.add_child(b)
			
			ConstructionInfo.Mode.DYNAMITE:
				if gold < tool.gold_cost:
					return
				
				var bp = get_building_part(grid_pos)
				if bp:
					if bp.building.placement_reason != BaseBuilding.PlacementReason.PLAYER:
						bp.building.queue_free()
						gold -= tool.gold_cost
				# TODO: update hotbar based on payable costs


func _refresh_preview() -> void:
	if _tool_preview:
		if _tool_preview is BaseBuilding:
			for p: BuildingPart in _tool_preview.parts:
				if p.has_meta(META_BUILD_BLOCKED_SIGN):
					var sgn: Sprite2D = p.get_meta(META_BUILD_BLOCKED_SIGN)
					sgn.queue_free()
					p.remove_meta(META_BUILD_BLOCKED_SIGN)
		_tool_preview.queue_free()
		_tool_preview = null
	var data = hotbar.get_data(hotbar.selected)
	if data is ConstructionInfo and data.mode == ConstructionInfo.Mode.BUILDING:
		_tool_preview = data.building_scene.instantiate()
		_tool_preview.is_preview = true
		if data.building_can_rotate:
			_tool_preview.grid_rot = _tool_rot
		_tool_preview.modulate.a = 0.75
		preview_root.add_child(_tool_preview)
		preview_root.position = (get_global_mouse_position() / GridMetric.GRID_PX).floor() * GridMetric.GRID_PX
		_check_tool_building_overlap()


func _check_tool_building_overlap() -> bool:
	assert(_tool_preview is BaseBuilding)
	var has_overlap = false
	for p: BuildingPart in _tool_preview.parts:
		var gp: Vector2i = Vector2i(preview_root.position / GridMetric.GRID_PX) + p.get_grid_pos()
		if get_tile_type(gp) != TileType.NOTHING:
			has_overlap = true
			if not p.has_meta(META_BUILD_BLOCKED_SIGN):
				var sgn := Sprite2D.new()
				sgn.texture = BUILD_BLOCKED_ICON
				sgn.centered = false
				sgn.z_index = 10
				sgn.position = Vector2(p.get_grid_pos()) * GridMetric.GRID_PX
				preview_root.add_child(sgn)
				p.set_meta(META_BUILD_BLOCKED_SIGN, sgn)
			else:
				var sgn: Sprite2D = p.get_meta(META_BUILD_BLOCKED_SIGN)
				sgn.position = Vector2(p.get_grid_pos()) * GridMetric.GRID_PX
		elif p.has_meta(META_BUILD_BLOCKED_SIGN):
			p.get_meta(META_BUILD_BLOCKED_SIGN).queue_free()
			p.remove_meta(META_BUILD_BLOCKED_SIGN)
	_tool_preview.modulate.a = 0.75 if not has_overlap else 0.5
	return has_overlap


func _on_hotbar_selection_changed() -> void:
	_refresh_preview()


func _on_map_toggle_button_pressed() -> void:
	recipe_map_panel.visible = not recipe_map_panel.visible


func _on_go_button_pressed() -> void:
	_do_dawn()


func _on_center_button_pressed() -> void:
	camera_2d.position = Vector2(WORLD_SIZE) * GridMetric.GRID_PX * 0.5


class RegisteredBuildingPart:
	var building: BaseBuilding
	var grid_pos: Vector2i
	var part: int
