extends RefCounted
class_name ItemInstance

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")

@export var item: Item
@export var value: int

var sprite: ItemSprite

func require_sprite() -> ItemSprite:
	if not sprite:
		sprite = ITEM_SPRITE.instantiate()
		sprite.item = item
		sprite.tree_exiting.connect(func (): sprite = null)
		Main.current.entity_root.add_child(sprite)
	return sprite


func free_sprite() -> void:
	if is_instance_valid(sprite) and not sprite.is_queued_for_deletion():
		sprite.queue_free()
	sprite = null
