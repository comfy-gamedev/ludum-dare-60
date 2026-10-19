extends Resource
class_name Recipe

enum Workshop {
	FACTORY_ONLY,
	BAKERY,
	CARPENTER,
	FORGE,
}

@export var ingredients: Array[RecipeItem]
@export var result: Item
@export var workshop: Workshop
