@tool
extends Texture2D
class_name CustomMipChain

@export var mips: Array[Texture2D]: set = set_mips

var _texture: ImageTexture = ImageTexture.new()


func _get_rid() -> RID:
	return _texture.get_rid()
 

func _get_width() -> int:
	return _texture.get_width()
 
 
func _get_height() -> int:
	return _texture.get_height()
 
 
func _has_alpha() -> bool:
	return _texture.has_alpha()
 

func _has_mipmaps() -> bool:
	return _texture.has_mipmaps()
 
 
func _get_mipmap_count() -> int:
	return _texture.get_mipmap_count()
 
 
func _is_pixel_opaque(x: int, y: int) -> bool:
	return _texture.get_image().get_pixel(x, y).a > 0.0
 
 
func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	_texture.draw(to_canvas_item, pos, modulate, transpose)
 
 
func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	_texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)
 
 
func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func set_mips(v: Array[Texture2D]) -> void:
	for m in mips:
		if m:
			Utils.ensure_disconnected(m.changed, _on_mip_changed)
	mips = v
	for m in mips:
		if m:
			Utils.ensure_connected(m.changed, _on_mip_changed)
	rebuild()


func _on_mip_changed() -> void:
	rebuild()
 

func rebuild() -> void:
	if mips.is_empty() or null in mips:
		return
	
	var img_data := PackedByteArray()
	
	for i in mips.size():
		var mip_img := mips[i].get_image()
		mip_img.convert(Image.FORMAT_RGBA8)
		assert(mip_img.get_mipmap_count() == 0)
		img_data.append_array(mip_img.get_data())
	
	@warning_ignore("integer_division")
	var rem_sz := Vector2i(mips[-1].get_width(), mips[-1].get_height())
	while rem_sz.x > 1 or rem_sz.y > 1:
		@warning_ignore("integer_division")
		rem_sz = (rem_sz / 2).maxi(1)
		var mip_img := Image.create_empty(rem_sz.x, rem_sz.y, false, Image.FORMAT_RGBA8)
		mip_img.fill(Color.MAGENTA)
		img_data.append_array(mip_img.get_data())
	
	var base := mips[0].get_image()
	
	_texture.set_image(Image.create_from_data(
		base.get_width(), base.get_height(), true, Image.FORMAT_RGBA8, img_data))
	
	emit_changed()
