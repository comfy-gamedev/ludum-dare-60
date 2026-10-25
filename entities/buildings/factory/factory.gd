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


func _place_item(part: BuildingPart, item_inst: ItemInstance) -> bool:
	var part_i = parts.find(part)
	var item_i = posmod(part_i - grid_rot, 4)
	if items[item_i]:
		return false
	
	items[item_i] = item_inst
	
	if items[0] and items[1] and items[2]:
		for s in 3:
			var spr = sprites[posmod(s + grid_rot, 4)]
			spr.play("craft")
		sprites[posmod(3 + grid_rot, 4)].play("output")
		items[3] = Cookbook.cook(Recipe.Workshop.FACTORY, [items[0], items[1], items[2]])
		for i in 3:
			items[i].free_sprite()
			items[i] = null
	
	_update.call_deferred()
	return true


func _take_item(part: BuildingPart) -> ItemInstance:
	var part_i = parts.find(part)
	var item_i = posmod(part_i - grid_rot, 4)
	assert(item_i == 3)
	var item_inst = items[item_i]
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
		var i = posmod(part + grid_rot, 4)
		sprites[i].sprite_frames = output_sprite_frames if part == 3 else input_sprite_frames
		sprites[i].offset = output_offset if part == 3 else input_offset
		parts[i].is_input = part < 3
		parts[i].is_output = not parts[i].is_input
		if items[part]:
			items[part].require_sprite().position = Vector2(_part_to_pos(part)) * GridMetric.GRID_PX
