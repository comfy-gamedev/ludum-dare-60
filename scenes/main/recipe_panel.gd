extends Panel
class_name RecipePanel

signal clicked()

@export var item: Item
@export var highlighted: bool = false: set = set_highlighted
@export var normal_style: StyleBox
@export var highlighted_style: StyleBox
@export var line_color_dim: Color
@export var line_color_bright: Color

@export var recipe_map: RecipeMap


var input_output_positions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

@onready var input_markers: Array[Marker2D] = [
	$InputMarker2D1,
	$InputMarker2D2,
	$InputMarker2D3,
]

@onready var output_marker: Marker2D = $OutputMarker2D

@onready var color_rect: ColorRect = $ColorRect
@onready var item_sprite: ItemSprite = $ColorRect/ItemSprite


func _ready() -> void:
	item_sprite.item = item
	_update()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()
			accept_event()


func _draw() -> void:
	var line_color = line_color_bright if highlighted else line_color_dim
	for i in 3:
		var inp_loc_pos := input_markers[i].position
		if input_output_positions[i] != Vector2.ZERO:
			var curve2d = Curve2D.new()
			curve2d.add_point(inp_loc_pos, Vector2(0, 0), Vector2(-8, 0))
			curve2d.add_point(input_output_positions[i], Vector2(8, 0), Vector2(0, 0))
			curve2d.bake_interval = 4
			var px = 0.0
			while px < curve2d.get_baked_length():
				var p1 = curve2d.sample_baked(px)
				var p2 = curve2d.sample_baked(px + 4.0)
				px += 4.0
				draw_line(p1, p2, line_color)
		else:
			draw_line(inp_loc_pos, inp_loc_pos + Vector2(-8, 0), line_color)
			draw_string(get_theme_default_font(), inp_loc_pos + Vector2(-16, 4), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, get_theme_default_font_size(), line_color)
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, Rect2(-10000, -10000, 20000, 20000))


func set_highlighted(v: bool) -> void:
	highlighted = v
	z_index = 1 if highlighted else 0
	_update.call_deferred()


func _update() -> void:
	if not is_node_ready() or not is_inside_tree():
		return
	color_rect.add_theme_stylebox_override("panel", highlighted_style if highlighted else normal_style)
	input_output_positions = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
	if not item: return
	var recipe: Recipe = Cookbook.product_to_recipe.get(item)
	if not recipe: return
	var rect = Rect2(Vector2.ZERO, size)
	for i in recipe.ingredients.size():
		var ing = recipe.ingredients[i]
		if ing is RecipeItemSingle:
			var inp_loc: Vector2 = input_markers[i].global_position
			var inp_out_loc: Vector2 = recipe_map.item_panels[ing.item].output_marker.global_position
			var inp_loc_pos := input_markers[i].position
			input_output_positions[i] = inp_loc_pos + inp_out_loc - inp_loc
			rect = rect.expand(input_output_positions[i])
	rect.position += position
	queue_redraw()
