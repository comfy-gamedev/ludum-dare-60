extends Node2D

const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")

var ticks = 9999
var logs = []

@export var item: Item

@onready var item_sprite: ItemSprite = $ItemSprite
@onready var rich_text_label_2: RichTextLabel = $RichTextLabel2

func _ready():
	ticks = Globals.elapsed_days
	if Globals.is_easy:
		item = preload("res://systems/crafting/items/bread.tres")
		item_sprite.item = item
		rich_text_label_2.text = rich_text_label_2.text.replace("tank", "bread")
	var Rich_label = $RichTextLabel
	if ticks <= 20:
		Rich_label.text = "You completed the ritual\n with a [wave amp=50.0 freq=5.0 connected=1][color=GOLD]GOLD[/color][/wave] Score!"
	elif ticks <= 40:
		Rich_label.text = "You completed the ritual\n with a [wave amp=50.0 freq=5.0 connected=1][color=SILVER]SILVER[/color][/wave] Score!"
	elif ticks <= 80:
		Rich_label.text = "You completed the ritual\n with a [wave amp=50.0 freq=5.0 connected=1][color=PERU]BRONZE[/color][/wave] Score!"
	else:
		Rich_label.text = "You completed the ritual\n with just a [wave amp=50.0 freq=5.0 connected=1][color=BROWN]TERRIBLE[/color][/wave] Score!"
	
	var score_label = $Label3
	score_label.text = "Days spent: " + str(ticks)


func _process(delta):#240 160
	for l in logs:
		if l:
			l.position += Vector2(-delta * 10, delta * 10)
			if l.position.y > 170 or l.position.x < -10:
				logs.erase(l)
				l.queue_free()

func _on_timer_timeout() -> void:
	var sprite := ITEM_SPRITE.instantiate()
	sprite.item = item
	sprite.position = Vector2(randi_range(10, 250), -10) if randi() % 2 == 0 else Vector2(250, randi_range(-10, 150))
	add_child(sprite)
	logs.append(sprite)


func _on_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/main_menu/main_menu.tscn")
