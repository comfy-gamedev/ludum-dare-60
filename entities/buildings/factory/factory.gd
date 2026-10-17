extends BaseBuilding

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")

var items: Array[ItemInstance] = [null, null, null, null]
var item_sprites: Array[ItemSprite] = [null, null, null, null]


func _ready() -> void:
	for part in 4:
		var quadpos = GridMetric.rot_to_quad(grid_rot + part)
		Main.current.building_add_part(self, grid_pos + quadpos, part)
		var spritepos = quadpos * GridMetric.GRID_PX
		var sp = ITEM_SPRITE.instantiate()
		sp.position = spritepos
		add_child(sp)
		item_sprites[part] = sp
	_update()


func _pos_to_part(pos: Vector2i) -> int:
	var quad = GridMetric.quad_to_rot(pos - grid_pos)
	var part = posmod(quad - grid_rot, 4)
	assert(quad == posmod(grid_rot + part, 4))
	return part


func can_place_item(pos: Vector2i) -> bool:
	var part = _pos_to_part(pos)
	return part < 3 and items[part] == null


func can_take_item(pos: Vector2i) -> bool:
	var part = _pos_to_part(pos)
	return part == 3 and items[part] != null


func place_item(pos: Vector2i, item_inst: ItemInstance) -> void:
	var part = _pos_to_part(pos)
	assert(part < 3)
	assert(items[part] == null)
	items[part] = item_inst
	_update.call_deferred()


func get_item(pos: Vector2i) -> ItemInstance:
	var part = _pos_to_part(pos)
	return items[part]


func take_item(pos: Vector2i) -> ItemInstance:
	var part = _pos_to_part(pos)
	assert(part == 3)
	assert(items[part] != null)
	var item_inst = items[part]
	items[part] = null
	_update.call_deferred()
	return item_inst


func _update() -> void:
	for part in 4:
		item_sprites[part].item = items[part].item if items[part] else null
