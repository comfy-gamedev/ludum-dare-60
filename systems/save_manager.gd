extends Node

enum SlotKind {
	AUTOSAVE,
}


func write_save(slot_kind: SlotKind, slot: int, raw_data: PackedByteArray) -> void:
	assert(slot == 0)
	match slot_kind:
		SlotKind.AUTOSAVE:
			var fname = _prepare_autosave_file(0)
			assert(not FileAccess.file_exists(fname))
			var f = FileAccess.open_compressed(fname, FileAccess.WRITE, FileAccess.COMPRESSION_ZSTD)
			if not f:
				printerr("Failed to open file for saving: %s (%s)" % [fname, error_string(FileAccess.get_open_error())])
				return
			var succ = f.store_64(raw_data.size())
			succ = succ and f.store_buffer(raw_data)
			if not succ:
				printerr("Failed to write save data: %s" % [fname])
				return
			print("Autosave: %s (%s raw bytes)" % [fname, raw_data.size()])


func has_save(slot_kind: SlotKind, slot: int) -> bool:
	match slot_kind:
		SlotKind.AUTOSAVE:
			var fname = "user://autosave_%s.sav" % slot
			return FileAccess.file_exists(fname)
	return false


func load_save(slot_kind: SlotKind, slot: int) -> PackedByteArray:
	match slot_kind:
		SlotKind.AUTOSAVE:
			var fname = "user://autosave_%s.sav" % slot
			assert(FileAccess.file_exists(fname))
			var f = FileAccess.open_compressed(fname, FileAccess.READ, FileAccess.COMPRESSION_ZSTD)
			if not f:
				printerr("Failed to open file for loading: %s (%s)" % [fname, error_string(FileAccess.get_open_error())])
				return PackedByteArray()
			var sz = f.get_64()
			var buf = f.get_buffer(sz)
			if not buf:
				printerr("Failed to load save data: %s" % [fname])
				return PackedByteArray()
			print("Loaded autosave: %s (%s raw bytes)" % [fname, buf.size()])
			return buf
	
	return PackedByteArray()


func _prepare_autosave_file(slot: int) -> String:
	var fname = "user://autosave_%s.sav" % slot
	if FileAccess.file_exists(fname):
		if slot >= 3:
			DirAccess.remove_absolute(fname)
		else:
			var new_fname = _prepare_autosave_file(slot + 1)
			DirAccess.rename_absolute(fname, new_fname)
	assert(not FileAccess.file_exists(fname))
	return fname
