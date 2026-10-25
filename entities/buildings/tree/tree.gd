extends BaseBuilding
class_name TreeEntity

@export var item: Item
@export var item_value: int = 1
@export var crow_limit: int = 4
@export var daily_limit: int = 6

var remaining: int = 0: set = set_remaining
var has_scarecrow: bool = false: set = set_has_scarecrow

var _has_crows: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var depleted_sprite_2d: Sprite2D = $DepletedSprite2D
@onready var animation_player: AnimationPlayer = $CrowAnimationPlayer
@onready var crows_sprite: AnimatedSprite2D = $CrowsSprite


func _ready() -> void:
	Main.current.register_tick_entity(self)
	remaining = daily_limit
	crows_sprite.frame = randi_range(0, 4)
	_update_visuals()
	update_crows()


func tick(t: int) -> void:
	if t == 0:
		remaining = daily_limit


func _place_item(_part: BuildingPart, _item_inst: ItemInstance) -> bool:
	assert(false)
	return false


func _take_item(_part: BuildingPart) -> ItemInstance:
	if remaining <= 0:
		return null
	if not has_scarecrow and remaining <= daily_limit - crow_limit:
		return null
	var item_inst = ItemInstance.new()
	item_inst.item = item
	item_inst.value = item_value
	remaining -= 1
	return item_inst


func set_remaining(v: int) -> void:
	if remaining == v:
		return
	remaining = v
	if is_node_ready():
		_update_visuals()


func set_has_scarecrow(v: bool) -> void:
	if has_scarecrow == v:
		return
	has_scarecrow = v
	if is_node_ready():
		_update_visuals()


func update_crows() -> void:
	has_scarecrow = Main.current.scarecrow_map.get(grid_pos, 0) > 0
	_update_visuals()


func _update_visuals() -> void:
	sprite_2d.visible = remaining > 0
	depleted_sprite_2d.visible = remaining == 0
	var should_have_crows = not has_scarecrow and remaining > 0 and remaining <= daily_limit - crow_limit
	if should_have_crows and not _has_crows:
		animation_player.play("land")
		_has_crows = true
	elif not should_have_crows and _has_crows:
		animation_player.play("fly")
		_has_crows = false
