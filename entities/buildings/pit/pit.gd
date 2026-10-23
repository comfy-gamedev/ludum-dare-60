extends BaseBuilding


func _place_item(_part: BuildingPart, item_inst: ItemInstance) -> bool:
	@warning_ignore("integer_division")
	Main.current.gold += item_inst.value / 2
	item_inst.free_sprite()
	return true


func _take_item(_part: BuildingPart) -> ItemInstance:
	assert(false)
	return null
