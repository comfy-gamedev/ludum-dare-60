@tool
extends Control

signal finished()

@export_tool_button("Play") var tool_cb0 = play_async
@export_tool_button("Play In") var tool_cb1 = play_in_async
@export_tool_button("Play Out") var tool_cb2 = play_out_async

@export var text: String = "":
	set(v):
		if v == text: return
		text = v
		_rebuild_layout()

@export var font: Font = null
@export var font_size: int = 0
@export var font_color: Color = Color.WHITE

@export_group("Wave In")
@export var wave_time: float = 0.5
@export var rise_time: float = 0.3
@export var rise_curve: Curve

@export_group("Idle Slosh")
@export var slosh_time: float = 0.5
@export var slosh_amplitude: Vector2 = Vector2(0.1, 0.1)
@export var slosh_speed: float = 1.0
@export var slosh_noise: Noise

@export_group("Wave Out")
@export var fall_time: float = 0.3
@export var fall_curve: Curve

var is_playing: bool = false

var _chars: Array[CharData] = []
var _text_height: float = 0.0
var _ascent: float = 0.0
var _idle_time: float = 0.0
var _tween: Tween


func _ready() -> void:
	_rebuild_layout()
	set_process(false)


func _process(delta: float) -> void:
	_idle_time += delta * slosh_speed
	queue_redraw()


func _draw() -> void:
	var actual_font = font if font != null else get_theme_default_font()
	var actual_size = font_size if font_size != 0 else get_theme_default_font_size()
	for cd in _chars:
		var pos := cd.base_pos + Vector2(0.0, cd.y_offset * size.y)
		pos += slosh_amplitude * Vector2(
			slosh_noise.get_noise_1d(cd.phase.x + _idle_time * slosh_speed),
			slosh_noise.get_noise_1d(cd.phase.y + _idle_time * slosh_speed))
		draw_string(actual_font, pos, cd.glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, actual_size, font_color)


func _get_minimum_size() -> Vector2:
	var actual_font = font if font != null else get_theme_default_font()
	var actual_size = font_size if font_size != 0 else get_theme_default_font_size()
	if text.is_empty():
		return Vector2.ZERO
	return Vector2(actual_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, actual_size).x, _text_height)


func play_async() -> void:
	is_playing = true
	await play_in_async()
	await get_tree().create_timer(slosh_time).timeout
	await play_out_async()
	is_playing = false
	finished.emit()


## Plays the rising "wave" entrance, then settles into idle slosh.
func play_in_async() -> void:
	_idle_time = 0.0
	
	var char_count := _chars.size()
	if char_count == 0:
		return
	
	set_process(true)
	
	var initial_y_offset: float = rise_curve.sample_baked(0.0)
	for cd in _chars:
		cd.y_offset = initial_y_offset
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_parallel(true)
	
	for i in char_count:
		var cd := _chars[i]
		var delay := i * wave_time / char_count
		_tween.tween_method(
			func (t):
				cd.y_offset = rise_curve.sample_baked(t),
			0.0, 1.0, rise_time).set_delay(delay)
	
	_tween.step_finished.connect(func(_i): queue_redraw())
	
	await _tween.finished


## Plays the drop-back-down exit animation. All chars fall together.
func play_out_async() -> void:
	var char_count := _chars.size()
	if char_count == 0:
		return
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_parallel(true)
	
	for i in char_count:
		var cd := _chars[i]
		_tween.tween_method(
			func (t):
				cd.y_offset = fall_curve.sample_baked(t),
			0.0, 1.0, fall_time)
	
	_tween.step_finished.connect(func(_i): queue_redraw())
	
	await _tween.finished
	
	set_process(false)


func _rebuild_layout() -> void:
	if _tween:
		_tween.kill()
		_tween = null
	
	_chars.clear()
	if text.is_empty():
		queue_redraw()
		update_minimum_size()
		return
	
	var actual_font = font if font != null else get_theme_default_font()
	var actual_size = font_size if font_size != 0 else get_theme_default_font_size()

	_ascent = actual_font.get_ascent(actual_size)
	_text_height = actual_font.get_height(actual_size)
	
	var x_cursor: float = 0.0
	for i in text.length():
		var ch := text[i]
		var cd := CharData.new()
		cd.glyph = ch
		cd.base_pos = Vector2(x_cursor, _ascent)
		cd.phase = Vector2(randf_range(0.0, 10000.0), randf_range(0.0, 10000.0))
		cd.y_offset = 1.0
		_chars.append(cd)
		var ch_sz = actual_font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, actual_size)
		x_cursor += ch_sz.x
	
	update_minimum_size()
	queue_redraw()


class CharData:
	var glyph: String
	var base_pos: Vector2
	var y_offset: float
	var phase: Vector2
