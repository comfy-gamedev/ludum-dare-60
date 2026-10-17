@abstract
extends RefCounted
class_name Cookbook

const RECIPE_DIR = "res://systems/crafting/recipes/"

static var recipes: Array[Recipe]

static func _static_init() -> void:
	for f in DirAccess.get_files_at(RECIPE_DIR):
		if f.ends_with(".tres"):
			var fname = RECIPE_DIR.path_join(f)
			recipes.append(load(fname))


static func cook(ingredients: Array[ItemInstance]) -> ItemInstance:
	var ing = ingredients.map(func (x): return x.item).duplicate()
	ing.sort()
	for r in recipes:
		var ring = r.ingredients.duplicate()
		ring.sort()
		if ing == ring:
			var result = ItemInstance.new()
			result.item = r.result
			result.value = ingredients.reduce(func (v, x): return v + x.value, 0)
			return result
	
	## TODO: junk recipe
	var result = ItemInstance.new()
	result.item = ingredients[0].result
	result.value = ingredients[0].value
	return result
