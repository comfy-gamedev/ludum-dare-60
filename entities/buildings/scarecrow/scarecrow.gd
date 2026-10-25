extends BaseBuilding
class_name Scarecrow

@export var scare_radius: float


func _ready() -> void:
	Main.current.register_scarecrow(self)


func _draw() -> void:
	if is_preview:
		var pts = GridMetric.points_in_circle(Vector2i.ZERO, scare_radius)
		for p in pts:
			var c = (Vector2(grid_pos + p) + Vector2(0.5, 0.5)) * GridMetric.GRID_PX
			var e = GridMetric.GRID_PX * 0.25
			draw_rect(Rect2(c - e, e * 2.0), Color(Color.YELLOW, 0.5), false, 2.0, false)
