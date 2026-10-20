extends BaseBuilding

var item: ItemInstance = null

@export var need: Item
@export var is_tutorial = false

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")

func _ready() -> void:
	Main.current.building_add_part(self, grid_pos, 0)
	var sprite : Sprite2D= ITEM_SPRITE.instantiate()
	sprite.item = need
	add_child(sprite)
	
	var t = create_tween().set_loops()
	t.tween_property(sprite, "modulate:a", 0.0, 0.5)
	t.tween_property(sprite, "modulate:a", 1.0, 0.5)


func can_place_item(_pos: Vector2i, item_type: Item) -> bool:
	return item == null and need == item_type


func can_take_item(_pos: Vector2i) -> bool:
	return false


func place_item(_pos: Vector2i, item_inst: ItemInstance) -> void:
	remove_child(get_child(0))
	item = item_inst
	item_inst.require_sprite().position = position
	#Main.current.objective_count += 1
	#if Main.current.objective_count >= Main.current.OBJECTIVE_GOAL:
	if is_tutorial:
		SceneGirl.change_scene("res://scenes/tutorials/tutorial_win.tscn")
	else:
		Globals.elapsed_days = Main.current.day_count
		SceneGirl.change_scene("res://scenes/end_scene/end_scene.tscn")


func get_item(_pos: Vector2i) -> ItemInstance:
	return item


func take_item(_pos: Vector2i) -> ItemInstance:
	return null
