extends Node2D
class_name Main

const TICK_RATE = 2.0
const PAN_SPEED = 16.0 * 10.0
const WORLD_SIZE = Vector2i(128, 128)
const CYCLE_END = 20
const OBJECTIVE_GOAL = 1

const META_REGISTERED_PARTS = &"Main__registered_parts"

const ERASE_ICON = preload("uid://r63jdvojly4a")

const HOUSE = preload("uid://6gtvs4ggkcwd")
const PIT = preload("uid://btc2onty6jr4i")
const HOMEBASE = preload("uid://xgk4sw8nurj8")
const OBJECTIVE = preload("uid://kc23kghe407a")

const BUSH = preload("uid://fohd4r7tj11x")
const CRYSTAL = preload("uid://bb3usincgqjfp")
const ROCK = preload("uid://cpag0rr03s5qo")
const TREE = preload("uid://bayold7n6brg0")
const WATER = preload("uid://ceiw0p6112gmu")

const RESOURCES = [BUSH, CRYSTAL, ROCK, TREE, WATER]

const CONSTRUCTIONS = [
	preload("uid://c0rrybc5bgfno"),
	preload("uid://nmq3klwu0rtw"),
	preload("uid://dihg3y5nmbf5i"),
	preload("uid://cniaep2ikgsjy"),
	preload("uid://bfkgt3wvanaqj"),
	preload("uid://c7sjwdmihoy6j"),
	preload("uid://c85aj58cwtkhk"),
]

const BASE_TILE_SOURCE = 1
const PATH_TILE_SOURCE = 2

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

var building_parts: Dictionary[Vector2i, BuildingPart]

var tick_entities: Dictionary[Node, bool] # HashSet
var pedestals: Array[BaseBuilding] = []

var gold: int = 5:
	set(val):
		gold = val
		gold_label.text = "Gold: " + str(val)

var objective_count = 0

var _ticking: bool = true
var _t: float = 0.0
var _tick_t: int = 0
var day_count: int = 0

var _tool_preview: Node2D
var _tool_rot: int = 0

func _ready() -> void:
	current = self
	
	gold_label.text = "Gold: " + str(gold)
	
	var hb = HOMEBASE.instantiate()
	@warning_ignore("integer_division")
	hb.grid_pos = WORLD_SIZE / 2
	entity_root.add_child(hb)
	
	var ob = OBJECTIVE.instantiate()
	@warning_ignore("integer_division")
	ob.grid_pos = (WORLD_SIZE / 2) + Vector2i(4, 0)
	entity_root.add_child(ob)
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			surface_tile_map_layer.set_cell(p, 1, Vector2i(0, 0))
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			if randi_range(0, 10) == 0 and get_tile_type(p) == TileType.NOTHING:
				var tree = RESOURCES.pick_random().instantiate()
				tree.grid_pos = p
				entity_root.add_child(tree)
	
	camera_2d.position = Vector2(WORLD_SIZE) * GridMetric.GRID_PX * 0.5
	camera_2d.limit_left = 0
	camera_2d.limit_top = 0
	camera_2d.limit_right = int(WORLD_SIZE.x * GridMetric.GRID_PX.x)
	camera_2d.limit_bottom = int(WORLD_SIZE.y * GridMetric.GRID_PX.y)
	
	hotbar.add_hotbar_item(ERASE_ICON)
	for c in CONSTRUCTIONS:
		hotbar.add_hotbar_item(c)


func _process(delta: float) -> void:
	var pan = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	if pan:
		camera_2d.position += pan * PAN_SPEED * delta / camera_2d.zoom
		# sync pos within limits
		(func (): camera_2d.position = camera_2d.get_screen_center_position()).call_deferred()
	
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
				_ticking = false
				animation_player.play("night")
				MusicMan.event("Nightstart1")
				day_count += 1
				break


func _tick() -> void:
	for ent: Node in tick_entities.keys():
		if is_instance_valid(ent) and not ent.is_queued_for_deletion():
			ent.tick(_tick_t)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_toggle"):
		camera_2d.zoom = Vector2(0.5, 0.5) if camera_2d.zoom == Vector2.ONE else Vector2.ONE
	
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
			_tool_preview.position = Vector2(gp) * GridMetric.GRID_PX
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var data = hotbar.get_data(hotbar.selected)
			if data is not ConstructionInfo or data.mode != ConstructionInfo.Mode.BUILDING:
				_do_tool(gp, data)


func _start_tickin() -> void:
	_ticking = true


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
	
	return TileType.NOTHING


func building_add_part(building: BaseBuilding, grid_pos: Vector2i, part: int) -> void:
	assert(grid_pos not in building_parts)
	var bp = BuildingPart.new()
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


func get_building_part(grid_pos: Vector2i) -> BuildingPart:
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


func _do_tool(grid_pos: Vector2i, tool: Variant) -> void:
	if tool == ERASE_ICON:
		var bp = get_building_part(grid_pos)
		if bp:
			if bp.building.placement_reason == BaseBuilding.PlacementReason.PLAYER:
				if bp.building is PedestalBuilding:
					pedestals.erase(bp.building)
				bp.building.get_parent().remove_child(bp.building)
				bp.building.queue_free()
				gold += bp.building.info.gold_cost
		else:
			if get_world_rect().has_point(grid_pos) and get_tile_type(grid_pos) != TileType.NOTHING:
				surface_tile_map_layer.set_cell(grid_pos, BASE_TILE_SOURCE, Vector2i(0, 0))
		
		# TODO: fixup neighbor tiles (make paths become unfinished again)
	
	elif tool is ConstructionInfo:
		match tool.mode:
			ConstructionInfo.Mode.TILE:
				if get_tile_type(grid_pos) == TileType.NOTHING:
					surface_tile_map_layer.set_cell(grid_pos, tool.tileset_source_id, tool.tileset_atlas_coord)
			
			ConstructionInfo.Mode.BUILDING:
				
				# check placement
				
				var placement_rect = tool.placement_size
				placement_rect.position += grid_pos
				for y in placement_rect.size.y:
					for x in placement_rect.size.x:
						if get_tile_type(placement_rect.position + Vector2i(x, y)) != TileType.NOTHING:
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
				
				# TODO: update hotbar based on payable costs


func _refresh_preview() -> void:
	if _tool_preview:
		_tool_preview.queue_free()
		_tool_preview = null
	var data = hotbar.get_data(hotbar.selected)
	if data is ConstructionInfo and data.mode == ConstructionInfo.Mode.BUILDING:
		_tool_preview = data.building_scene.instantiate()
		_tool_preview.is_preview = true
		_tool_preview.position = Vector2((get_global_mouse_position() / GridMetric.GRID_PX).floor()) * GridMetric.GRID_PX
		if data.building_can_rotate:
			_tool_preview.grid_rot = _tool_rot
		_tool_preview.modulate.a = 0.5
		preview_root.add_child(_tool_preview)


func _on_hotbar_selection_changed() -> void:
	_refresh_preview()


class BuildingPart:
	var building: BaseBuilding
	var grid_pos: Vector2i
	var part: int
