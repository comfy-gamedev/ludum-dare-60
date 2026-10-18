extends HBoxContainer

signal selection_changed()

const META_DATA = &"Hotbar__data"

var selected: int = 0

var button_group: ButtonGroup


func _ready() -> void:
	button_group = ButtonGroup.new()
	button_group.pressed.connect(_button_group_pressed)


func _button_group_pressed(button: BaseButton) -> void:
	selected = button.get_index()
	selection_changed.emit()


func add_hotbar_item(thing: Variant) -> int:
	var btn = Button.new()
	btn.toggle_mode = true
	btn.button_group = button_group
	add_child(btn)
	
	if thing is Texture2D:
		btn.icon = thing
		btn.set_meta(META_DATA, thing)
	elif thing is ConstructionInfo:
		btn.icon = thing.icon
		btn.set_meta(META_DATA, thing)
		thing.hotbar_index = btn.get_index()
	
	return btn.get_index()


func get_data(i: int) -> Variant:
	return get_child(i).get_meta(META_DATA)
