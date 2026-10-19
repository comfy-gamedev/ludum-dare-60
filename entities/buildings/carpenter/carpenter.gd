extends BaseBuilding


func _ready() -> void:
	if is_preview:
		return
	
	Main.current.building_add_part(self, grid_pos + Vector2i(-1, -1), 0)
	Main.current.building_add_part(self, grid_pos + Vector2i(-1, 0), 0)
	Main.current.building_add_part(self, grid_pos + Vector2i(0, -1), 0)
	Main.current.building_add_part(self, grid_pos, 0)
	Main.current.building_add_part(self, grid_pos + Vector2i(2, -1), 0)
	Main.current.building_add_part(self, grid_pos + Vector2i(2, 0), 0)


func can_place_item(_pos: Vector2i, _item: Item) -> bool:
	return false


func can_take_item(_pos: Vector2i) -> bool:
	return false


func place_item(_pos: Vector2i, _item_inst: ItemInstance) -> void:
	pass


func get_item(_pos: Vector2i) -> ItemInstance:
	return null


func take_item(_pos: Vector2i) -> ItemInstance:
	return null
