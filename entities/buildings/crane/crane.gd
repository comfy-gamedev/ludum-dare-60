extends BaseBuilding

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")
const SLOT_OPEN = 2
const SLOT_CLOSED = 0

var item: ItemInstance

@onready var crane: Sprite2D = $Crane
@onready var item_slot: RemoteTransform2D = $ItemSlot


func _init() -> void:
	grid_transform_changed.connect(_grid_transform_changed)


func _ready() -> void:
	if is_preview:
		_update()
		return
	
	Main.current.building_add_part(self, grid_pos, 0)
	
	Main.current.register_tick_entity(self)
	
	_update()


func is_flipped() -> bool:
	return grid_rot % 2 == 1


func tick(t: int) -> void:
	if t == Main.CYCLE_END:
		if item and item.sprite:
			item.sprite.queue_free()
		item = null
		_update()


func _grid_transform_changed() -> void:
	_update.call_deferred()


func can_place_item(pos: Vector2i, _item_type: Item) -> bool:
	assert(pos == grid_pos)
	return item == null


func can_place_item_from(pos: Vector2i, from_pos: Vector2i) -> bool:
	assert(pos == grid_pos)
	var d = from_pos - grid_pos
	assert(abs(d.x) + abs(d.y) == 1)
	return (d == Vector2i.LEFT) if not is_flipped() else (d == Vector2i.RIGHT)


func can_take_item(pos: Vector2i) -> bool:
	assert(pos == grid_pos)
	return item != null


func can_take_item_from(pos: Vector2i, from_pos: Vector2i) -> bool:
	assert(pos == grid_pos)
	var d = from_pos - grid_pos
	assert(abs(d.x) + abs(d.y) == 1)
	return (d == Vector2i.RIGHT) if not is_flipped() else (d == Vector2i.LEFT)


func place_item(pos: Vector2i, item_inst: ItemInstance) -> void:
	assert(pos == grid_pos)
	assert(item == null)
	item = item_inst
	
	_update.call_deferred()


func get_item(_pos: Vector2i) -> ItemInstance:
	return item


func take_item(_pos: Vector2i) -> ItemInstance:
	assert(item != null)
	var item_inst = item
	item = null
	_update.call_deferred()
	return item_inst


func _update() -> void:
	if not is_node_ready() or not is_inside_tree():
		return
	
	crane.flip_h = is_flipped()
	crane.frame = 0 if item == null else 2
	item_slot.position.x = -16 if (item == null) == (not is_flipped()) else 16
	item_slot.remote_path = item.require_sprite().get_path() if item else ^""
