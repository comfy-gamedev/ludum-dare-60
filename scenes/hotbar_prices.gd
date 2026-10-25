extends Panel
@export
var info: ConstructionInfo
@onready var rich_text_label: RichTextLabel = $RichTextLabel

@onready var item_sprite: ItemSprite = $CanvasGroup/ItemSprite
@onready var sprite_2d: Sprite2D = $CanvasGroup/Sprite2D

func _ready() -> void:
	rich_text_label.text = "$" + str(info.gold_cost)
	item_sprite.item = info.item_req
	sprite_2d.visible = info.item_req != null
