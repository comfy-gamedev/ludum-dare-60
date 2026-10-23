@tool
extends Node2D
class_name BuildingPart

const COLOR_BOTH = Color.WHITE
const COLOR_INPUT = Color.RED
const COLOR_OUTPUT = Color.CYAN
const COLOR_NONE = Color.BLACK

const ACCEPT_W = 1 << 0
const ACCEPT_N = 1 << 1
const ACCEPT_E = 1 << 2
const ACCEPT_S = 1 << 3

static var _editor_texture: Texture2D

@export var is_input: bool = false: set = set_is_input
@export var is_output: bool = false: set = set_is_output

@export_flags("W", "N", "E", "S") var accept_dirs: int = 0b1111: set = set_accept_dirs

var items: Array[ItemInstance]


func _ready() -> void:
	if Engine.is_editor_hint():
		set_notify_local_transform(true)
		return
	
	get_parent().register_part(self)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	if not _editor_texture:
		_editor_texture = load("res://systems/building/building_part_editor.png")
		if not _editor_texture:
			_editor_texture = Texture2D.new()
	var cols = [[COLOR_NONE, COLOR_OUTPUT], [COLOR_INPUT, COLOR_BOTH]]
	var col = Color(cols[int(is_input)][int(is_output)], 0.5)
	draw_texture(_editor_texture, Vector2.ZERO, col)
	for d in GridMetric.DIRS:
		if accepts_dir(d):
			draw_circle(Vector2(Vector2i.ONE + d) * 0.5 * GridMetric.GRID_PX, 4.0, col, true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		set_notify_local_transform(false)
		position = position.snapped(GridMetric.GRID_PX)
		set_notify_local_transform(true)


func get_grid_pos() -> Vector2i:
	return Vector2i((position / GridMetric.GRID_PX).floor())


func accepts_dir(dir: Vector2i) -> bool:
	return accept_dirs & (1 << GridMetric.dir_to_rot(dir))


func set_is_input(v: bool) -> void:
	is_input = v
	if Engine.is_editor_hint():
		queue_redraw()


func set_is_output(v: bool) -> void:
	is_output = v
	if Engine.is_editor_hint():
		queue_redraw()


func set_accept_dirs(v: int) -> void:
	accept_dirs = v
	if Engine.is_editor_hint():
		queue_redraw()
