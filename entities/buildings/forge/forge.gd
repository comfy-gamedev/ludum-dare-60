extends BaseBuilding

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")
const SLOT_OPEN = 2
const SLOT_CLOSED = 0

var items: Array[ItemInstance] = []
var result: ItemInstance

func _init() -> void:
	grid_transform_changed.connect(_grid_transform_changed)


func _ready() -> void:
	if is_preview:
		_update()
		return
	
	Main.current.building_add_part(self, grid_pos + Vector2i(-1, -1), 2)
	Main.current.building_add_part(self, grid_pos + Vector2i(-1, 0), 0)
	Main.current.building_add_part(self, grid_pos, 1)
	Main.current.building_add_part(self, grid_pos + Vector2i(0, -1), 2)
	
	_update()


func _pos_to_part(pos: Vector2i) -> int:
	match pos - grid_pos:
		Vector2i(-2, 0): return 1
		_: return 0


func _grid_transform_changed() -> void:
	_update.call_deferred()


func can_place_item(pos: Vector2i, _item_type: Item) -> bool:
	var part = _pos_to_part(pos)
	return part == 0 and result == null and items.size() < 3


func can_take_item(pos: Vector2i) -> bool:
	var part = _pos_to_part(pos)
	return part == 1 and result != null


func place_item(pos: Vector2i, item_inst: ItemInstance) -> void:
	var part = _pos_to_part(pos)
	print("place_item(%s, %s), part = %s" % [pos, item_inst, part])
	assert(part == 0)
	assert(items.size() < 3)
	items.append(item_inst)
	
	if not items.is_empty():
		result = Cookbook.cook(Recipe.Workshop.FORGE, items)
		if result:
			for item in items:
				if item.sprite:
					item.sprite.queue_free()
			items.clear()
	
	_update.call_deferred()


func get_item(pos: Vector2i) -> ItemInstance:
	var part = _pos_to_part(pos)
	return result if part == 1 else null


func take_item(pos: Vector2i) -> ItemInstance:
	var part = _pos_to_part(pos)
	assert(part == 1)
	assert(items.is_empty())
	assert(result != null)
	var item_inst = result
	result = null
	_update.call_deferred()
	return item_inst


func _update() -> void:
	if not is_node_ready() or not is_inside_tree():
		return
	
	for item in items:
		item.require_sprite().position = Vector2(grid_pos + Vector2i(-1, 0)) * GridMetric.GRID_PX
	if result:
		result.require_sprite().position = Vector2(grid_pos + Vector2i(0, 0)) * GridMetric.GRID_PX
