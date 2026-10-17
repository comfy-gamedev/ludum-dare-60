@abstract
extends Node2D
class_name BaseBuilding

signal grid_transform_changed()

enum PlacementReason {
	WORLDGEN,
	PLAYER,
}

var grid_pos: Vector2i: set = set_grid_pos
var grid_rot: int: set = set_grid_rot

var placement_reason: PlacementReason = PlacementReason.WORLDGEN

var is_preview: bool = false

@abstract func can_place_item(pos: Vector2i) -> bool

@abstract func can_take_item(pos: Vector2i) -> bool

@abstract func place_item(pos: Vector2i, item_inst: ItemInstance) -> void

@abstract func get_item(pos: Vector2i) -> ItemInstance

@abstract func take_item(pos: Vector2i) -> ItemInstance


func set_grid_pos(v: Vector2i) -> void:
	if grid_pos == v: return
	grid_pos = v
	position = Vector2(grid_pos) * GridMetric.GRID_PX


func set_grid_rot(v: int) -> void:
	if grid_rot == v: return
	grid_rot = v
	grid_transform_changed.emit()
