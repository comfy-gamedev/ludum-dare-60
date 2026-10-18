extends RecipeItem
class_name RecipeItemKind

@export var kind: Item.Kind

func matches(item: Item) -> bool:
	return item.kind == kind
