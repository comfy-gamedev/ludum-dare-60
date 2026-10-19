extends Node2D

const ROT_SPEED = 3.0


func _process(delta: float) -> void:
	rotation += ROT_SPEED * delta
