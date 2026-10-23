extends BaseBuilding


func _init() -> void:
	grid_transform_changed.connect(_grid_transform_changed)


func _ready() -> void:
	if is_preview:
		_update()
		return
	
	_update()


func _grid_transform_changed() -> void:
	_update.call_deferred()


func _place_item(_part: BuildingPart, item_inst: ItemInstance) -> bool:
	item_inst.free_sprite()
	Main.current.gold += item_inst.value
	_update.call_deferred()
	return true


func _take_item(_part: BuildingPart) -> ItemInstance:
	assert(false)
	return null


func _update() -> void:
	pass
