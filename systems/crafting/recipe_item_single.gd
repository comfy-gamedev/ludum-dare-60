extends RecipeItem
class_name RecipeItemSingle

@export var item: Item

func matches(p_item: Item) -> bool:
	return item == p_item
