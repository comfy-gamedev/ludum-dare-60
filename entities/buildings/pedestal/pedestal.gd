extends BaseBuilding
class_name PedestalBuilding
#
#var item: ItemInstance = null
#
#
#func _ready() -> void:
#	if not is_preview:
#		Main.current.building_add_part(self, grid_pos, 0)
#
#
#func can_place_item(_pos: Vector2i, _item_type: Item) -> bool:
#	return item == null
#
#
#func can_take_item(_pos: Vector2i) -> bool:
#	return false
#
#
#func place_item(_pos: Vector2i, item_inst: ItemInstance) -> void:
#	item = item_inst
#	item_inst.require_sprite().position = position + Vector2(0, -4)
#
#
#func get_item(_pos: Vector2i) -> ItemInstance:
#	return item
#
#
#func take_item(_pos: Vector2i) -> ItemInstance:
#	return null
