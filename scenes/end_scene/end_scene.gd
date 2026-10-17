extends Node2D

var ticks = 9999
var logs = []

@export var item: Item
const ITEM_SPRITE = preload("uid://b6ueuaycfmiyo")

func _ready():
	ticks = Globals.elapsed_days
	var Rich_label = $RichTextLabel
	if ticks < 1000:
		Rich_label.text = "You completed the ritual\n with a [wave amp=50.0 freq=5.0 connected=1][color=GOLD]GOLD[/color][/wave] Score!"
	elif ticks < 2000:
		Rich_label.text = "You completed the ritual\n with a [wave amp=50.0 freq=5.0 connected=1][color=SILVER]SILVER[/color][/wave] Score!"
	elif ticks < 4000:
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
	SceneGirl.change_scene("res://scenes/main/main.tscn")
