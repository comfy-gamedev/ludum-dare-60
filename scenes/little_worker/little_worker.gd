class_name LittleWorker
extends Node2D

signal walk_done
signal work_done

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var walk_speed: float = 5.0
@export var work_speed: float = 1.0

var facing_dir: Vector2i = Vector2i.DOWN
var walk_tween: Tween
var work_timer: SceneTreeTimer
var _item_instance: ItemInstance


func _process(_delta: float) -> void:
	if _item_instance:
		var item_sprite = _item_instance.require_sprite()
		item_sprite.position = sprite_2d.global_position + sprite_2d.offset + Vector2(0, -8 - 7 * (sprite_2d.frame % 2))


func walk_to(grid_pos: Vector2i) -> void:
	if walk_tween and walk_tween.is_valid() and walk_tween.is_running():
		walk_tween.kill()
	
	var target_pos: Vector2 = GridMetric.grid_to_world(grid_pos)
	var dir: Vector2 = position.direction_to(target_pos)
	if absf(dir.x) >= absf(dir.y):
		if dir.x >= 0:
			facing_dir = Vector2i.RIGHT
		else:
			facing_dir = Vector2i.LEFT
	else:
		if dir.y >= 0:
			facing_dir = Vector2i.DOWN
		else:
			facing_dir = Vector2i.UP
	
	animation_player.stop(true)
	animation_player.play(LittleGuy.dir_animations[facing_dir], -1, Main.TICK_RATE * 2)
	
	walk_tween = create_tween()
	walk_tween.tween_property(self, "position", target_pos,
		maxf(GridMetric.world_to_grid(position).distance_to(grid_pos)/ walk_speed, 0))
	walk_tween.tween_callback(walk_done.emit)
	walk_tween.tween_callback(func():
		animation_player.stop(true)
		sprite_2d.frame -= sprite_2d.frame % 2
		sprite_2d.flip_h = facing_dir == Vector2i.RIGHT
	)
	
	_start_or_continue_animation("walk")


func do_work(amount: float) -> void:
	_start_or_continue_animation("work")
	work_timer = get_tree().create_timer(amount / work_speed)
	work_timer.timeout.connect(func():
		work_timer = null
		animation_player.stop()
		work_done.emit()
	)


func hold_item(item: Item) -> void:
	_item_instance = ItemInstance.new()
	_item_instance.item = item
	_item_instance.value = 1
	


func _exit_tree() -> void:
	if _item_instance and _item_instance.sprite:
		_item_instance.sprite.queue_free()


func _start_or_continue_animation(animation: StringName) -> void:
	if animation_player.has_animation(animation) and not (animation_player.current_animation == animation and animation_player.is_playing()):
		animation_player.play(animation)
