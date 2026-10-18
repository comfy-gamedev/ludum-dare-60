@tool
extends Resource
class_name ConstructionInfo

enum Mode {
	BUILDING,
	TILE,
}

@export var icon: Texture2D

@export var mode: Mode: set = set_mode

@export var building_scene: PackedScene
@export var building_can_rotate: bool

@export var tileset_source_id: int
@export var tileset_atlas_coord: Vector2i

@export var gold_cost: int
@export var item_req: Item

var hotbar_index: int = -1


func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("building_") and mode != Mode.BUILDING:
		property.usage &= ~PROPERTY_USAGE_EDITOR
	if property.name.begins_with("tileset_") and mode != Mode.TILE:
		property.usage &= ~PROPERTY_USAGE_EDITOR


func set_mode(v: Mode) -> void:
	mode = v
	notify_property_list_changed()
