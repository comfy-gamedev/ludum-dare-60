extends HBoxContainer


@export var frame_off: StyleBox
@export var frame_on: StyleBox


var selected: int = 0


func _ready() -> void:
	for c: Control in get_children():
		c.gui_input.connect(_panel_gui_input.bind(c.get_index()))
	_update()


func _panel_gui_input(event: InputEvent, i: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected = i
			_update.call_deferred()
			accept_event()


func _update() -> void:
	for c: Control in get_children():
		if c.get_index() == selected:
			c.add_theme_stylebox_override("panel", frame_on)
		else:
			c.add_theme_stylebox_override("panel", frame_off)
