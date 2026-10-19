extends BaseBuilding
class_name FactoryBuilding

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")

@export var input_sprite_frames: SpriteFrames
@export var output_sprite_frames: SpriteFrames

var items: Array[ItemInstance] = [null, null, null, null]

@onready var sprites: Array[AnimatedSprite2D] = [
	$SlotSprite0,
	$SlotSprite1,
	$SlotSprite2,
	$SlotSprite3,
]
@onready var input_offset: Vector2 = $SlotSprite0.offset
@onready var output_offset: Vector2 = $SlotSprite3.offset

func _init() -> void:
	grid_transform_changed.connect(_grid_transform_changed)


func _ready() -> void:
	if is_preview:
		_update()
		return
	
	for part in 4:
		Main.current.building_add_part(self, _part_to_pos(part), part)
		assert(_pos_to_part(_part_to_pos(part)) == part) # unit test
	Main.current.register_tick_entity(self)
	
	_update()


func tick(t: int) -> void:
	if t == Main.CYCLE_END:
		for i in 4:
			if items[i]:
				if items[i].sprite:
					items[i].sprite.queue_free()
			items[i] = null
		_update()


func _part_to_pos(part: int) -> Vector2i:
	return grid_pos + GridMetric.rot_to_quad(grid_rot + part)


func _pos_to_part(pos: Vector2i) -> int:
	var quad = GridMetric.quad_to_rot(pos - grid_pos)
	var part = posmod(quad - grid_rot, 4)
	assert(quad == posmod(grid_rot + part, 4))
	return part


func _grid_transform_changed() -> void:
	_update.call_deferred()


func can_place_item(pos: Vector2i, _item_type: Item) -> bool:
	var part = _pos_to_part(pos)
	return part < 3 and items[part] == null and items[3] == null


func can_take_item(pos: Vector2i) -> bool:
	var part = _pos_to_part(pos)
	return part == 3 and items[part] != null


func place_item(pos: Vector2i, item_inst: ItemInstance) -> void:
	var part = _pos_to_part(pos)
	print("place_item(%s, %s), part = %s" % [pos, item_inst, part])
	assert(part < 3)
	assert(items[part] == null)
	items[part] = item_inst
	
	if items[0] and items[1] and items[2]:
		for s in 3:
			var spr = sprites[posmod(s + grid_rot, 4)]
			spr.play("craft")
		sprites[posmod(3 + grid_rot, 4)].play("output")
		items[3] = Cookbook.cook(Recipe.Workshop.FACTORY, [items[0], items[1], items[2]])
		for i in 3:
			if items[i].sprite:
				items[i].sprite.queue_free()
			items[i] = null
	
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
	if not is_node_ready() or not is_inside_tree():
		return
	
	if not is_preview:
		Main.current.building_teardown(self)
		for part in 4:
			Main.current.building_add_part(self, _part_to_pos(part), part)
	
	for part in 4:
		sprites[posmod(part + grid_rot, 4)].sprite_frames = output_sprite_frames if part == 3 else input_sprite_frames
		sprites[posmod(part + grid_rot, 4)].offset = output_offset if part == 3 else input_offset
		if items[part]:
			items[part].require_sprite().position = Vector2(_part_to_pos(part)) * GridMetric.GRID_PX
