extends BaseBuilding

@export var item: Item


func _ready() -> void:
	Main.current.building_add_part(self, grid_pos, 0)


func can_place_item(pos: Vector2i, _item_type: Item) -> bool:
	assert(pos == grid_pos)
	return false


func can_take_item(pos: Vector2i) -> bool:
	assert(pos == grid_pos)
	return true


func place_item(_pos: Vector2i, _item_inst: ItemInstance) -> void:
	assert(false)


func get_item(_pos: Vector2i) -> ItemInstance:
	return null


func take_item(pos: Vector2i) -> ItemInstance:
	assert(pos == grid_pos)
	var item_inst = ItemInstance.new()
	item_inst.item = item
	item_inst.value = 1
	return item_inst
