extends BaseBuilding

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")
const SLOT_OPEN = 2
const SLOT_CLOSED = 0

#var items: Array[ItemInstance] = [null, null, null, null, null, null, null, null]

var slot_pos: Array[Vector2i] = [
	Vector2i(1, 1),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(1, 0),
]

@onready var sprites: Array[Sprite2D] = [
	$SlotSprite0,
	$SlotSprite1,
	$SlotSprite2,
	$SlotSprite3,
	$SlotSprite4,
	$SlotSprite5,
	$SlotSprite6,
	$SlotSprite7,
]

@onready var folk_band: Node2D = $FolkBand

func _init() -> void:
	grid_transform_changed.connect(_grid_transform_changed)


func _ready() -> void:
	if is_preview:
		_update()
		return
	
	for part in 9:
		Main.current.building_add_part(self, _part_to_pos(part), part)
	
	_update()
	
	Main.current.dawn.connect(_on_dawn)
	Main.current.dusk.connect(_on_dusk)
	folk_band.hide()


func _on_dawn() -> void:
	folk_band.hide()


func _on_dusk() -> void:
	folk_band.show()



func _part_to_pos(part: int) -> Vector2i:
	if part == 8:
		return grid_pos
	return grid_pos + slot_pos[part]


func _pos_to_part(pos: Vector2i) -> int:
	var pp = pos - grid_pos
	if pp == Vector2i.ZERO:
		return 8
	assert(pp in slot_pos)
	return slot_pos.find(pp)


func _grid_transform_changed() -> void:
	_update.call_deferred()


func can_place_item(pos: Vector2i, _item_type: Item) -> bool:
	var part = _pos_to_part(pos)
	if part == 8: return false
	return true


func can_take_item(_pos: Vector2i) -> bool:
	return false


func place_item(pos: Vector2i, item_inst: ItemInstance) -> void:
	var part = _pos_to_part(pos)
	print("place_item(%s, %s), part = %s" % [pos, item_inst, part])
	assert(part < 8)
	#assert(items[part] == null)
	#items[part] = item_inst
	if item_inst.sprite:
		item_inst.sprite.queue_free()
	Main.current.gold += item_inst.value
	_update.call_deferred()


func get_item(_pos: Vector2i) -> ItemInstance:
	return null


func take_item(_pos: Vector2i) -> ItemInstance:
	assert(false)
	return null


func _update() -> void:
	pass
	#for part in 8:
	#	if items[part]:
	#		items[part].require_sprite().position = Vector2(_part_to_pos(part)) * GridMetric.GRID_PX
