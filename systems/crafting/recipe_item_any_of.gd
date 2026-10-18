extends RecipeItem
class_name RecipeItemAnyOf

@export var items: Array[Item]

func matches(item: Item) -> bool:
	return item in items
