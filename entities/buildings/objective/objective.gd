extends BaseBuilding

var item: ItemInstance = null

@export var need: Item

func _ready() -> void:
	Main.current.building_add_part(self, grid_pos, 0)


func can_place_item(_pos: Vector2i, item_type: Item) -> bool:
	return item == null and need == item_type


func can_take_item(_pos: Vector2i) -> bool:
	return false


func place_item(_pos: Vector2i, item_inst: ItemInstance) -> void:
	item = item_inst
	item_inst.sprite.position = position


func get_item(_pos: Vector2i) -> ItemInstance:
	return item


func take_item(_pos: Vector2i) -> ItemInstance:
	return null
