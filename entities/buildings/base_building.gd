@abstract
extends Node2D
class_name BaseBuilding

signal grid_transform_changed()

@warning_ignore("unused_signal")
signal mouse_entered()
@warning_ignore("unused_signal")
signal mouse_exited()

enum PlacementReason {
	WORLDGEN,
	PLAYER,
}

var grid_pos: Vector2i: set = set_grid_pos
var grid_rot: int: set = set_grid_rot

var placement_reason: PlacementReason = PlacementReason.WORLDGEN

var is_preview: bool = false
var info: ConstructionInfo

var parts: Array[BuildingPart]

@export var is_resource: bool = false


func try_place_item(pos: Vector2i, from_dir: Vector2i, item_inst: ItemInstance) -> bool:
	var p_pos = pos - grid_pos
	for p in parts:
		if p.get_grid_pos() == p_pos:
			if p.is_input and p.accepts_dir(from_dir):
				return _place_item(p, item_inst)
			else:
				return false
	return false


func try_take_item(pos: Vector2i, from_dir: Vector2i) -> ItemInstance:
	var p_pos = pos - grid_pos
	for p in parts:
		if p.get_grid_pos() == p_pos:
			if p.is_output and p.accepts_dir(from_dir):
				return _take_item(p)
			else:
				return null
	return null


func _place_item(_part: BuildingPart, _item_inst: ItemInstance) -> bool:
	assert(false)
	return false


func _take_item(_part: BuildingPart) -> ItemInstance:
	assert(false)
	return null


func register_part(part: BuildingPart) -> void:
	if is_preview:
		return
	Main.current.building_add_part(self, grid_pos + part.get_grid_pos(), parts.size())
	parts.append(part)


func set_grid_pos(v: Vector2i) -> void:
	if grid_pos == v: return
	grid_pos = v
	position = Vector2(grid_pos) * GridMetric.GRID_PX


func set_grid_rot(v: int) -> void:
	if grid_rot == v: return
	grid_rot = v
	grid_transform_changed.emit()
