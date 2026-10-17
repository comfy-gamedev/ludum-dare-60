@tool
extends EditorScript


func _run() -> void:
	var palette: Image = load("uid://bqawbh17kxtkw")
	var palcolors := PackedColorArray()
	for y in palette.get_height():
		for x in palette.get_width():
			var c = palette.get_pixel(x, y)
			if c.a != 1.0:
				continue
			palcolors.append(c)
	var sz = 16
	var sz2 = 4
	var img := Image.create_empty(sz * sz2, sz * sz2, false, Image.FORMAT_RGBA8)
	for z in sz:
		for y in sz:
			for x in sz:
				var rgb := Color(float(x) / float(sz - 1), float(y) / float(sz - 1), float(z) / float(sz - 1))
				var hsl := Vector3(rgb.ok_hsl_h, rgb.ok_hsl_s, rgb.ok_hsl_l)
				var closest := Color()
				var dist := INF
				for p in palcolors:
					var phsl = Vector3(p.ok_hsl_h, p.ok_hsl_s, p.ok_hsl_l)
					var dv := Vector3(
						minf(fposmod(hsl.x - phsl.x, 1.0), fposmod(phsl.x - hsl.x, 1.0)),
						hsl.y - phsl.y,
						hsl.z - phsl.z)
					var d := sqrt(dv.dot(dv))#hsl.distance_to(phsl)
					#print(d - )
					if d < dist:
						dist = d
						closest = p
				@warning_ignore("integer_division")
				img.set_pixel(z % 4 * sz + x, z / 4 * sz + y, closest)
	img.save_png("res://systems/palette_shader/lut.png")
	EditorInterface.get_resource_filesystem().scan()
