extends BaseBuilding

func _ready() -> void:
	Main.current.building_add_part(self, grid_pos, 0)


func can_place_item(_pos: Vector2i, _item_type: Item) -> bool:
	return true


func can_take_item(_pos: Vector2i) -> bool:
	return false


func place_item(_pos: Vector2i, item_inst: ItemInstance) -> void:
	@warning_ignore("integer_division")
	Main.current.gold += item_inst.value / 2
	if item_inst.sprite:
		item_inst.sprite.queue_free()


func get_item(_pos: Vector2i) -> ItemInstance:
	return null


func take_item(_pos: Vector2i) -> ItemInstance:
	return null
