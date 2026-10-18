extends BaseBuilding

const LITTLE_GUY = preload("uid://bgsxcf5vjn2kd")
const LOG = preload("uid://dr8h1qvukffh4")
const ENTRANCE_OFFSET := Vector2i(0, 1)
const LOGGING_GUY_SCENE: PackedScene = preload("uid://b4hl887uugbdp")
const TREE_WORK: float = 5.0
const GATHER_RADIUS: float = 5.0
const START_DELAY: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $CabinAnimatedSprite2D

var _active: bool = false
var _logging_guy: LittleWorker
var _delay_timer: SceneTreeTimer

enum {
	START,
	WALK_TO_TREE,
	CUT_IT,
	WALK_BACK
}

var _logging_state: int = START


func _ready() -> void:
	if is_preview:
		return
	
	Main.current.register_tick_entity(self)
	Main.current.building_add_part(self, grid_pos, 0)
	Main.current.building_add_part(self, grid_pos + Vector2i(-1, 0), 0)


func tick(t: int) -> void:
	if t == Main.CYCLE_END:
		_reset()
		return
	
	if not _active:
		for ent in Main.current.tick_entities:
			if ent is LittleGuy:
				if ent.grid_pos == grid_pos + ENTRANCE_OFFSET and not ent.is_holding_item():
					set_active(true)
					ent.grid_facing = Vector2i.UP
					ent.grid_pos = grid_pos
					ent.animation_player.play("enter_up", -1, Main.TICK_RATE * 2)
					ent.animation_player.advance(0)
					await ent.animation_player.animation_finished
					ent.queue_free()
					_delay_timer = get_tree().create_timer(START_DELAY)
					_delay_timer.timeout.connect(_start_logger)
					break


func _start_logger() -> void:
	_logging_guy = LOGGING_GUY_SCENE.instantiate()
	_logging_guy.position = GridMetric.grid_to_world(grid_pos)
	Main.current.entity_root.add_child(_logging_guy)
	_logging_guy.walk_done.connect(_next_logging_state)
	_logging_guy.work_done.connect(_next_logging_state)
	_next_logging_state()


func _next_logging_state() -> void:
	match _logging_state:
		START:
			_logging_state = WALK_TO_TREE
			var walk_pos: Vector2i = GridMetric.world_to_grid(_get_closest_tree().position)
			if walk_pos.x < grid_pos.x:
				walk_pos += Vector2i(1, 0)
			else:
				walk_pos -= Vector2i(1, 0)
			_logging_guy.walk_to(walk_pos)
		WALK_TO_TREE:
			_logging_state = CUT_IT
			_logging_guy.do_work(TREE_WORK)
		CUT_IT:
			_logging_state = WALK_BACK
			_logging_guy.hold_item(LOG)
			_logging_guy.walk_to(grid_pos + ENTRANCE_OFFSET)
		WALK_BACK:
			_reset()
			var new_guy: LittleGuy = LITTLE_GUY.instantiate()
			new_guy.grid_pos = grid_pos + ENTRANCE_OFFSET
			new_guy.grid_facing = Vector2i.DOWN
			var log_inst := ItemInstance.new()
			log_inst.item = LOG
			log_inst.value = 1
			new_guy.hold_item(log_inst)
			get_parent().add_child(new_guy)


func set_active(value: bool) -> void:
	if value == _active:
		return
	
	_active = value
	animated_sprite.play("active" if _active else "inactive")


func _get_closest_tree() -> TreeEntity:
	var tree: TreeEntity = null
	var closest_dist: float = 0.0
	
	for ent in Main.current.entity_root.get_children():
		if ent is TreeEntity:
			var dist: float = grid_pos.distance_to(GridMetric.world_to_grid(ent.position))
			if not tree or (dist <= GATHER_RADIUS and dist < closest_dist):
				tree = ent
				closest_dist = dist
	
	return tree


func _reset() -> void:
	set_active(false)
	_logging_state = START
	if _delay_timer:
		_delay_timer.timeout.disconnect(_start_logger)
		_delay_timer = null
	if _logging_guy:
		_logging_guy.queue_free()


func can_place_item(_pos: Vector2i, _item: Item) -> bool:
	return false


func can_take_item(_pos: Vector2i) -> bool:
	return false


func place_item(_pos: Vector2i, _item_inst: ItemInstance) -> void:
	pass


func get_item(_pos: Vector2i) -> ItemInstance:
	return null


func take_item(_pos: Vector2i) -> ItemInstance:
	return null
