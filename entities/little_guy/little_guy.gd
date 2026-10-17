extends Node2D

var grid_pos: Vector2i: set = set_grid_pos
var grid_facing: Vector2i = Vector2i.DOWN: set = set_grid_facing

var _held_item: ItemInstance

@onready var line_2d: Line2D = $Line2D


func _ready() -> void:
	Main.current.register_tick_entity(self)
	line_2d.rotation = GridMetric.dir_to_rot(grid_facing) * TAU / 4.0


func _process(_delta: float) -> void:
	if _held_item:
		var sprite = _held_item.require_sprite()
		sprite.position = position + Vector2(0, -8)


func _exit_tree() -> void:
	if _held_item and _held_item.sprite:
		_held_item.sprite.queue_free()


func tick(t: int) -> void:
	if t == Main.CYCLE_END:
		queue_free()
		return
	
	if Main.current.get_tile_type(grid_pos) == Main.TileType.PATH:
		for turn in [0, 1, 3]:
			var lookdir = GridMetric.rotate_dir(grid_facing, turn)
			var look = grid_pos + lookdir
			if Main.current.get_tile_type(look) == Main.TileType.PATH:
				Main.current.connect_paths(grid_pos, look)
				grid_pos = look
				grid_facing = lookdir
				break
	
	for side in [0, 1, 3, 2]:
		var lookdir = GridMetric.rotate_dir(grid_facing, side)
		var look = grid_pos + lookdir
		if Main.current.get_tile_type(look) == Main.TileType.BUILDING:
			var bp = Main.current.get_building_part(look)
			if bp:
				if not _held_item:
					if bp.building.can_take_item(look):
						_held_item = bp.building.take_item(look)
				else:
					if bp.building.can_place_item(look, _held_item.item):
						bp.building.place_item(look, _held_item)
						_held_item = null


func set_grid_pos(v: Vector2i) -> void:
	if grid_pos == v: return
	grid_pos = v
	position = Vector2(grid_pos) * GridMetric.GRID_PX


func set_grid_facing(v: Vector2i) -> void:
	if grid_facing == v: return
	grid_facing = v
	if line_2d:
		line_2d.rotation = GridMetric.dir_to_rot(grid_facing) * TAU / 4.0
