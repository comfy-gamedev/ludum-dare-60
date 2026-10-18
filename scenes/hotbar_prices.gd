extends Panel
@export
var info: ConstructionInfo
@onready var rich_text_label: RichTextLabel = $RichTextLabel

@onready var item_sprite: ItemSprite = $ItemSprite

func _ready() -> void:
	rich_text_label.text = str(info.gold_cost)
	item_sprite.item = info.item_req
