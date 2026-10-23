extends BaseBuilding

var item: ItemInstance

@onready var crane: Sprite2D = $Crane
@onready var item_slot: RemoteTransform2D = $ItemSlot
@onready var part: BuildingPart = $BuildingPart

func _init() -> void:
	grid_transform_changed.connect(_grid_transform_changed)


func _ready() -> void:
	if is_preview:
		_update()
		return
	
	Main.current.register_tick_entity(self)
	
	_update()


func is_flipped() -> bool:
	return grid_rot % 2 == 1


func tick(t: int) -> void:
	if t == Main.CYCLE_END:
		if item and item.sprite:
			item.sprite.queue_free()
		item = null
		_update()


func _grid_transform_changed() -> void:
	_update.call_deferred()


func _place_item(_part: BuildingPart, item_inst: ItemInstance) -> bool:
	if item:
		return false
	
	item = item_inst
	_update.call_deferred()
	return true


func _take_item(_part: BuildingPart) -> ItemInstance:
	var item_inst = item
	item = null
	_update.call_deferred()
	return item_inst


func _update() -> void:
	if not is_node_ready() or not is_inside_tree():
		return
	
	crane.flip_h = is_flipped()
	crane.frame = 0 if item == null else 2
	item_slot.position.x = -16 if (item == null) == (not is_flipped()) else 16
	item_slot.remote_path = item.require_sprite().get_path() if item else ^""
	
	part.is_input = item == null
	part.is_output = not part.is_input
	part.accept_dirs = BuildingPart.ACCEPT_W if (not is_flipped() != part.is_input) else BuildingPart.ACCEPT_E
