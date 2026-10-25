@tool
extends EditorPlugin

var cmp: CMP

func _enter_tree() -> void:
	cmp = CMP.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, cmp)


func _exit_tree() -> void:
	remove_context_menu_plugin(cmp)
	cmp = null


class CMP extends EditorContextMenuPlugin:
	func _popup_menu(paths: PackedStringArray) -> void:
		if paths.size() == 1 and paths[0].ends_with(".png"):
			add_context_menu_item("Create CustomMipChain", _create_mipchain)
	
	func _create_mipchain(paths: PackedStringArray) -> void:
		var p: String = paths[0]
		var mip1_p: String = paths[0].get_basename() + "_mip1.png"
		var chain_p: String = paths[0].get_basename() + "_mipchain.tres"
		
		if FileAccess.file_exists(chain_p):
			printerr("%s already exists" % chain_p)
			return
		
		var tex0: Texture2D = load(p)
		if not FileAccess.file_exists(mip1_p):
			var img0 = tex0.get_image()
			var img1 = Image.create_empty(img0.get_width() / 2, img0.get_height() / 2, false, img0.get_format())
			for y in img1.get_height():
				for x in img1.get_width():
					img1.set_pixel(x, y, img0.get_pixel(x * 2, y * 2))
			img1.save_png(mip1_p)
			EditorInterface.get_resource_filesystem().update_file(mip1_p)
			EditorInterface.get_resource_filesystem().reimport_files([mip1_p])
			
		var tex1: Texture2D = load(mip1_p)
		
		var chain := CustomMipChain.new()
		chain.mips = [tex0, tex1]
		ResourceSaver.save(chain, chain_p)
