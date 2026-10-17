extends Node2D
class_name Main

const TICK_RATE = 2.0
const PAN_SPEED = 16.0 * 10.0
const WORLD_SIZE = Vector2i(128, 128)
const CYCLE_END = 20

const META_REGISTERED_PARTS = &"Main__registered_parts"

const HOUSE = preload("uid://6gtvs4ggkcwd")
const TREE = preload("uid://bayold7n6brg0")
const PIT = preload("uid://btc2onty6jr4i")

static var current: Main

enum TileType {
	INVALID,
	NOTHING,
	PATH,
	BUILDING,
}

enum ToolKind {
	SURFACE,
	BUILDING,
	ERASE,
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

var gold: int = 5:
	set(val):
		gold = val
		gold_label.text = "Gold: " + str(val)

var _ticking: bool = true
var _t: float = 0.0
var _tick_t: int = 0

var _tool_preview: Node2D

func _ready() -> void:
	current = self
	
	for y in WORLD_SIZE.y:
		for x in WORLD_SIZE.x:
			var p := Vector2i(x, y)
			surface_tile_map_layer.set_cell(p, 1, Vector2i(0, 0))
			if randi_range(0, 10) == 0:
				var tree = TREE.instantiate()
				tree.grid_pos = p
				entity_root.add_child(tree)
	
	camera_2d.position = Vector2(WORLD_SIZE) * GridMetric.GRID_PX * 0.5
	camera_2d.limit_left = 0
	camera_2d.limit_top = 0
	camera_2d.limit_right = int(WORLD_SIZE.x * GridMetric.GRID_PX.x)
	camera_2d.limit_bottom = int(WORLD_SIZE.y * GridMetric.GRID_PX.y)
	
	hotbar.add_hotbar_item(preload("uid://ctrope6st2ckv"), [ToolKind.SURFACE, [1, Vector2i(1, 0)]])
	hotbar.add_hotbar_item(preload("uid://ixjui85tt6wx"), [ToolKind.BUILDING, [preload("uid://6gtvs4ggkcwd"), false]])
	hotbar.add_hotbar_item(preload("uid://bxo6h0qpw2tyl"), [ToolKind.BUILDING, [preload("uid://qwy22yet3em5"), true]])
	hotbar.add_hotbar_item(preload("uid://bxo6h0qpw2tyl"), [ToolKind.BUILDING, [preload("uid://cy1ktd1fykiqy"), false]])
	hotbar.add_hotbar_item(preload("uid://r63jdvojly4a"), [ToolKind.ERASE, []])


func _process(delta: float) -> void:
	var pan = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	if pan:
		camera_2d.position += pan * PAN_SPEED * delta
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
				break


func _tick() -> void:
	for ent: Node in tick_entities.keys():
		if is_instance_valid(ent) and not ent.is_queued_for_deletion():
			ent.tick(_tick_t)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var gp: Vector2i = Vector2i((get_viewport().canvas_transform.affine_inverse() * event.position / GridMetric.GRID_PX).floor())
			_do_tool(gp, hotbar.get_data(hotbar.selected))
	
	elif event is InputEventMouseMotion:
		var gp: Vector2i = Vector2i((get_viewport().canvas_transform.affine_inverse() * event.position / GridMetric.GRID_PX).floor())
		if _tool_preview:
			_tool_preview.position = Vector2(gp) * GridMetric.GRID_PX
		if hotbar.get_data(hotbar.selected)[0] != ToolKind.BUILDING and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_do_tool(gp, hotbar.get_data(hotbar.selected))


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
		[1, Vector2i(1, 0)]: return TileType.PATH
	
	return TileType.NOTHING


func building_add_part(building: BaseBuilding, grid_pos: Vector2i, part: int) -> void:
	assert(grid_pos not in building_parts)
	var bp = BuildingPart.new()
	bp.building = building
	bp.grid_pos = grid_pos
	bp.part = part
	building_parts[grid_pos] = bp
	var meta = building.get_meta(META_REGISTERED_PARTS, [])
	meta.append([grid_pos, part])
	building.set_meta(META_REGISTERED_PARTS, meta)
	Utils.ensure_connected(building.tree_exiting, building_teardown, CONNECT_APPEND_SOURCE_OBJECT)


func building_remove_part(building: BaseBuilding, grid_pos: Vector2i, part: int) -> void:
	assert(grid_pos in building_parts)
	assert(building_parts[grid_pos].building == building)
	assert(building_parts[grid_pos].part == part)
	building_parts.erase(grid_pos)


func building_teardown(building: BaseBuilding) -> void:
	print("teardown ", building)
	for parts in building.get_meta(META_REGISTERED_PARTS):
		building_remove_part(building, parts[0], parts[1])
	Utils.ensure_disconnected(building.tree_exiting, building_teardown)


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


func _do_tool(grid_pos: Vector2i, tool: Array) -> void:
	match tool:
		[ToolKind.SURFACE, var cell]:
			if get_tile_type(grid_pos) == TileType.NOTHING:
				surface_tile_map_layer.set_cell(grid_pos, cell[0], cell[1])
		[ToolKind.BUILDING, var bld]:
			if get_tile_type(grid_pos) == TileType.NOTHING:
				var b = bld[0].instantiate()
				if gold < b.gold_cost:
					b.queue_free()
					return
				gold -= b.gold_cost
				b.placement_reason = BaseBuilding.PlacementReason.PLAYER
				b.grid_pos = grid_pos
				entity_root.add_child(b)
		[ToolKind.ERASE, _]:
			var bp = get_building_part(grid_pos)
			if bp:
				if bp.building.placement_reason == BaseBuilding.PlacementReason.PLAYER:
					bp.building.get_parent().remove_child(bp.building)
					bp.building.queue_free()
			else:
				if get_world_rect().has_point(grid_pos) and get_tile_type(grid_pos) != TileType.NOTHING:
					surface_tile_map_layer.set_cell(grid_pos, 1, Vector2i(0, 0))


func _on_hotbar_selection_changed() -> void:
	if _tool_preview:
		_tool_preview.queue_free()
		_tool_preview = null
	var data = hotbar.get_data(hotbar.selected)
	if data[0] == ToolKind.BUILDING:
		_tool_preview = data[1][0].instantiate()
		_tool_preview.is_preview = true
		_tool_preview.modulate.a = 0.5
		preview_root.add_child(_tool_preview)


class BuildingPart:
	var building: BaseBuilding
	var grid_pos: Vector2i
	var part: int
