extends PanelContainer
class_name RecipeMap

const PANEL_STRIDE = Vector2(40.0, 30.0)

const RECIPE_PANEL = preload("uid://sd2nxy7pm5gd")

var item_panels: Dictionary[Item, RecipePanel]

var rank_counts: Dictionary[int, int]

@onready var recipe_map_control: Control = $ScrollContainer/RecipeMapControl

func _ready() -> void:
	for item in Cookbook.items:
		_ensure_panel_for(item)


func _ensure_panel_for(item: Item) -> RecipePanel:
	var rp: RecipePanel = item_panels.get(item)
	if rp:
		return rp
	
	var recipe: Recipe = Cookbook.product_to_recipe.get(item)
	if recipe:
		for ing in recipe.ingredients:
			if ing is RecipeItemSingle:
				_ensure_panel_for(ing.item)
	
	rank_counts[item.rank] = rank_counts.get(item.rank, 0) + 1
	rp = RECIPE_PANEL.instantiate()
	rp.position.x = PANEL_STRIDE.x * item.rank
	rp.position.y = PANEL_STRIDE.y * rank_counts[item.rank]
	rp.item = item
	rp.recipe_map = self
	item_panels[item] = rp
	recipe_map_control.add_child(rp)
	rp.clicked.connect(_clicked.bind(item))
	recipe_map_control.custom_minimum_size = recipe_map_control.custom_minimum_size.max(rp.get_rect().end)
	return rp


func _clicked(item: Item) -> void:
	for i in item_panels:
		item_panels[i].highlighted = i == item
