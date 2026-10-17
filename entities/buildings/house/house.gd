extends BaseBuilding

const LITTLE_GUY = preload("uid://bgsxcf5vjn2kd")

@export var item: Item

var can_spawn: bool = true

func _ready() -> void:
	if is_preview:
		return
	
	Main.current.register_tick_entity(self)
	Main.current.building_add_part(self, grid_pos, 0)


func tick(t: int) -> void:
	if t == 0:
		can_spawn = true
	
	if can_spawn:
		var lg = LITTLE_GUY.instantiate()
		lg.grid_pos = grid_pos + Vector2i.DOWN
		lg.grid_facing = Vector2i.DOWN
		get_parent().add_child(lg)
		can_spawn = false


func can_place_item(pos: Vector2i) -> bool:
	assert(pos == grid_pos)
	return false


func can_take_item(pos: Vector2i) -> bool:
	assert(pos == grid_pos)
	return false


func place_item(_pos: Vector2i, _item_inst: ItemInstance) -> void:
	assert(false)


func get_item(_pos: Vector2i) -> ItemInstance:
	return null


func take_item(_pos: Vector2i) -> ItemInstance:
	assert(false)
	return null
