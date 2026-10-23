extends BaseBuilding
class_name TreeEntity

@export var item: Item
@export var item_value: int = 1
@export var daily_limit: int = 3

var remaining: int = 0: set = set_remaining

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var depleted_sprite_2d: Sprite2D = $DepletedSprite2D


func _ready() -> void:
	Main.current.register_tick_entity(self)
	remaining = daily_limit
	sprite_2d.visible = remaining > 0
	depleted_sprite_2d.visible = remaining == 0


func tick(t: int) -> void:
	if t == 0:
		remaining = daily_limit


func _place_item(_part: BuildingPart, _item_inst: ItemInstance) -> bool:
	assert(false)
	return false


func _take_item(_part: BuildingPart) -> ItemInstance:
	if remaining <= 0:
		return null
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
