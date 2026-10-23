extends AnimatedSprite2D


func _ready() -> void:
	(get_parent() as BaseBuilding).mouse_entered.connect(_on_mouse_entered)
	(get_parent() as BaseBuilding).mouse_exited.connect(_on_mouse_exited)
	if not (get_parent() as BaseBuilding).is_preview:
		hide()


func _on_mouse_entered() -> void:
	show()


func _on_mouse_exited() -> void:
	hide()
