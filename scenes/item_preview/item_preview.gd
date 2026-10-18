extends Node2D

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")


func _ready() -> void:
	var p = Vector2(0, 0)
	for item in Cookbook.items:
		var s: ItemSprite = ITEM_SPRITE.instantiate()
		s.item = item
		s.position = p
		add_child(s)
		p.x += 16
		if p.x >= get_viewport().size.x:
			p.x = 0.0
			p.y += 16.0
