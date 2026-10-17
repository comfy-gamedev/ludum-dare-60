extends Node2D

var ticks = 9999

func _ready():
	var Rich_label = $RichTextLabel
	if ticks < 1000:
		Rich_label.text = "You completed the ritual with a [wave amp=50.0 freq=5.0 connected=1][color=GOLD]GOLD[/color][/wave] Score!"
	elif ticks < 2000:
		Rich_label.text = "You completed the ritual with a [wave amp=50.0 freq=5.0 connected=1][color=SILVER]SILVER[/color][/wave] Score!"
	elif ticks < 4000:
		Rich_label.text = "You completed the ritual with a [wave amp=50.0 freq=5.0 connected=1][color=PERU]BRONZE[/color][/wave] Score!"
	else:
		Rich_label.text = "You completed the ritual with just a [wave amp=50.0 freq=5.0 connected=1][color=BROWN]TERRIBLE[/color][/wave] Score!"
	
	var score_label = $Label3
	score_label.text = "Days spent: \n" + str(ticks)
