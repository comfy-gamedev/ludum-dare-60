extends BaseBuilding
class_name WorkshopBuilding

var items: Array[ItemInstance] = []
var result: ItemInstance

@export var kind: Recipe.Workshop
@export var gimbal: ItemGimbal
@export var building_sprite: AnimatedSprite2D


func _init() -> void:
	grid_transform_changed.connect(_grid_transform_changed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		_update()
		if is_preview:
			return
		Main.current.register_tick_entity(self)


func tick(t: int) -> void:
	if t == Main.CYCLE_END:
		for item in items:
			item.free_sprite()
			gimbal.remove_item(item)
		items.clear()
		if result:
			result.free_sprite()
			result = null
		_update()


func _grid_transform_changed() -> void:
	_update.call_deferred()


func _place_item(_part: BuildingPart, item_inst: ItemInstance) -> bool:
	if result:
		return false
	
	items.append(item_inst)
	gimbal.add_item(item_inst)
	
	if not items.is_empty():
		result = Cookbook.cook(kind, items)
		if result:
			for item in items:
				item.free_sprite()
				gimbal.remove_item(item)
			items.clear()
	
	_update.call_deferred()
	
	return true


func _take_item(_part: BuildingPart) -> ItemInstance:
	var item_inst = result
	result = null
	_update.call_deferred()
	return item_inst


func _update() -> void:
	if not is_node_ready() or not is_inside_tree():
		return
	
	if result:
		for p in parts:
			if p.is_output:
				result.require_sprite().position = Vector2(grid_pos + p.get_grid_pos()) * GridMetric.GRID_PX
				break
	
	if not items.is_empty():
		building_sprite.play("active")
	else:
		building_sprite.play("inactive")
