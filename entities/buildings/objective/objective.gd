extends BaseBuilding

var item: ItemInstance = null

@export var need: Item
@export var is_tutorial = false

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")

func _ready() -> void:
	var sprite : Sprite2D= ITEM_SPRITE.instantiate()
	sprite.item = need
	add_child(sprite)
	
	var t = create_tween().set_loops()
	t.tween_property(sprite, "modulate:a", 0.0, 0.5)
	t.tween_property(sprite, "modulate:a", 1.0, 0.5)


func _place_item(_part: BuildingPart, item_inst: ItemInstance) -> bool:
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
	return true


func _take_item(_part: BuildingPart) -> ItemInstance:
	assert(false)
	return null
