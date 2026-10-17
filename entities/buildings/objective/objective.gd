extends BaseBuilding

var item: ItemInstance = null

@export var need: Item

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")

func _ready() -> void:
	Main.current.building_add_part(self, grid_pos, 0)
	var sprite : Sprite2D= ITEM_SPRITE.instantiate()
	sprite.item = need
	sprite.modulate = Color(1, 1, 1, .5)
	add_child(sprite)


func can_place_item(_pos: Vector2i, item_type: Item) -> bool:
	return item == null and need == item_type


func can_take_item(_pos: Vector2i) -> bool:
	return false


func place_item(_pos: Vector2i, item_inst: ItemInstance) -> void:
	remove_child(get_child(0))
	item = item_inst
	item_inst.sprite.position = position
	Main.current.objective_count += 1
	if Main.current.objective_count >= Main.current.OBJECTIVE_GOAL:
		Globals.elapsed_days = Main.current.day_count
		SceneGirl.change_scene("res://scenes/end_scene/end_scene.tscn")


func get_item(_pos: Vector2i) -> ItemInstance:
	return item


func take_item(_pos: Vector2i) -> ItemInstance:
	return null
