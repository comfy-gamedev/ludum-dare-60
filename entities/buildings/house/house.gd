extends BaseBuilding

const LITTLE_GUY = preload("uid://bgsxcf5vjn2kd")

@export var item: Item

var can_spawn: bool = true

func _ready() -> void:
	if is_preview:
		return
	Main.current.register_tick_entity(self)


func tick(t: int) -> void:
	if t == 0:
		can_spawn = true
	
	if can_spawn and Main.current.get_tile_type(grid_pos + Vector2i(0, 1)) == Main.TileType.PATH:
		var lg = LITTLE_GUY.instantiate()
		lg.grid_pos = grid_pos + Vector2i.DOWN
		lg.grid_facing = Vector2i.DOWN
		get_parent().add_child(lg)
		can_spawn = false


func _place_item(_part: BuildingPart, _item_inst: ItemInstance) -> bool:
	assert(false)
	return false


func _take_item(_part: BuildingPart) -> ItemInstance:
	assert(false)
	return null
