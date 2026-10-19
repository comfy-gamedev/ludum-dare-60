class_name TreeEntity
extends BaseBuilding

@export var item: Item
@export var item_value: int = 1
@export var daily_limit: int = 3

var remaining: int = 0: set = set_remaining

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var depleted_sprite_2d: Sprite2D = $DepletedSprite2D


func _ready() -> void:
	Main.current.building_add_part(self, grid_pos, 0)
	Main.current.register_tick_entity(self)
	remaining = daily_limit
	sprite_2d.visible = remaining > 0
	depleted_sprite_2d.visible = remaining == 0


func tick(t: int) -> void:
	if t == 0:
		remaining = daily_limit


func can_place_item(pos: Vector2i, _item_type: Item) -> bool:
	assert(pos == grid_pos)
	return false


func can_take_item(pos: Vector2i) -> bool:
	assert(pos == grid_pos)
	return remaining > 0


func place_item(_pos: Vector2i, _item_inst: ItemInstance) -> void:
	assert(false)


func get_item(_pos: Vector2i) -> ItemInstance:
	return null


func take_item(pos: Vector2i) -> ItemInstance:
	assert(pos == grid_pos)
	assert(remaining > 0)
	var item_inst = ItemInstance.new()
	item_inst.item = item
	item_inst.value = item_value
	remaining -= 1
	return item_inst


func set_remaining(v: int) -> void:
	remaining = v
	if is_node_ready():
		sprite_2d.visible = remaining > 0
		depleted_sprite_2d.visible = remaining == 0
