@abstract
extends RefCounted
class_name Cookbook

const ITEM_DIR = "res://systems/crafting/items/"
const RECIPE_DIR = "res://systems/crafting/recipes/"

const JUNKU = preload("uid://dv1k55g0qm17d")

static var items: Array[Item]

static var recipes: Array[Recipe]


static func _static_init() -> void:
	for f in DirAccess.get_files_at(ITEM_DIR):
		if f.ends_with(".tres"):
			var fname = ITEM_DIR.path_join(f)
			items.append(load(fname))
	
	for f in DirAccess.get_files_at(RECIPE_DIR):
		if f.ends_with(".tres"):
			var fname = RECIPE_DIR.path_join(f)
			recipes.append(load(fname))


static func cook(workshop: Recipe.Workshop, ingredients: Array[ItemInstance]) -> ItemInstance:
	# maximum bipartite matching
	# kuhn's algorithm
	# network flow! thank you dr plank
	
	var n := ingredients.size()
	var valid: Array[Recipe] = []
	
	var ingredient_to_recipe_slot: PackedInt32Array
	ingredient_to_recipe_slot.resize(n)
	
	var ingredients_used: Array[bool]
	ingredients_used.resize(n)
	
	var try_assign := func (recipe: Recipe, slot_i: int, recurse: Callable) -> bool:
		for ing_i in n:
			if ingredients_used[ing_i] or not recipe.ingredients[slot_i].matches(ingredients[ing_i].item):
				continue
			ingredients_used[ing_i] = true
			if ingredient_to_recipe_slot[ing_i] == -1 or recurse.call(recipe, ingredient_to_recipe_slot[ing_i], recurse):
				ingredient_to_recipe_slot[ing_i] = slot_i
				return true
		return false
	
	var workshop_recipes: Array[Recipe] = recipes
	if workshop != Recipe.Workshop.FACTORY:
		workshop_recipes = workshop_recipes.filter(func (r): return r.workshop == workshop)
	
	for recipe in workshop_recipes:
		if recipe.ingredients.size() != n:
			continue
		
		ingredient_to_recipe_slot.fill(-1)
		
		var complete := true
		for recipe_slot_i in n:
			ingredients_used.fill(false)
			if not try_assign.call(recipe, recipe_slot_i, try_assign):
				complete = false
				break
		if complete:
			valid.append(recipe)
	
	var result_item: Item = JUNKU
	
	if not valid.is_empty():
		result_item = valid.pick_random().result # idk this could probably be improved
	
	var item_inst := ItemInstance.new()
	item_inst.item = result_item
	item_inst.value = ingredients.reduce(func (v, i): return v + i.value, 0)
	@warning_ignore("integer_division")
	item_inst.value += maxi(item_inst.value / 3, 1)
	
	return item_inst
