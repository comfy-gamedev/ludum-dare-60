@tool
extends RecipeItem
class_name RecipeItemSingle

@export var item: Item: set = set_item


func set_item(v: Item) -> void:
	item = v
	if v: resource_name = v.name


func matches(p_item: Item) -> bool:
	return item == p_item
