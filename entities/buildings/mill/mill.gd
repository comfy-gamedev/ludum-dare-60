extends BaseBuilding
#
#
#func _ready() -> void:
#	if is_preview:
#		return
#	
#	Main.current.register_tick_entity(self)
#	Main.current.building_add_part(self, grid_pos, 0)
#	Main.current.building_add_part(self, grid_pos + Vector2i(-1, 0), 0)
#	Main.current.building_add_part(self, grid_pos + Vector2i(0, -1), 0)
#	Main.current.building_add_part(self, grid_pos + Vector2i(-1, -1), 0)
#
#
#func tick(t: int) -> void:
#	if t == Main.CYCLE_END:
#		_reset()
#		return
#	
#	
#
#
#func _reset() -> void:
#	pass
#
#
#func can_place_item(_pos: Vector2i, _item: Item) -> bool:
#	return false
#
#
#func can_take_item(_pos: Vector2i) -> bool:
#	return false
#
#
#func place_item(_pos: Vector2i, _item_inst: ItemInstance) -> void:
#	pass
#
#
#func get_item(_pos: Vector2i) -> ItemInstance:
#	return null
#
#
#func take_item(_pos: Vector2i) -> ItemInstance:
#	return null
