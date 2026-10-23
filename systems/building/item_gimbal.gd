extends Node2D
class_name ItemGimbal

const ROT_SPEED = 3.0

@onready var item_slots: Array[Node2D] = [
	$ItemSlot,
	$ItemSlot2,
	$ItemSlot3,
]

var items: Array[ItemInstance]


func _ready() -> void:
	set_process(not items.is_empty())


func _process(delta: float) -> void:
	rotation += ROT_SPEED * delta
	for i in items.size():
		items[i].require_sprite().global_position = item_slots[i].to_global(Vector2(8, 8))


func add_item(item: ItemInstance) -> void:
	assert(items.size() < 3)
	assert(item not in items)
	items.append(item)
	set_process(not items.is_empty())


func remove_item(item: ItemInstance) -> void:
	assert(item in items)
	items.erase(item)
	set_process(not items.is_empty())
