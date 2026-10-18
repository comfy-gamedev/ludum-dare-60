@tool
extends EditorScript

func _run() -> void:
	var img: Image = load("uid://bqawbh17kxtkw")
	var pal := PackedColorArray()
	for y in img.get_height():
		for x in img.get_width():
			pal.append(img.get_pixel(x, y))
	var p := ColorPalette.new()
	p.colors = pal
	ResourceSaver.save(p, "res://assets/palette.tres")
