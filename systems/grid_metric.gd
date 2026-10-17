@tool
@abstract
extends RefCounted
class_name GridMetric

const GRID_PX = Vector2(16.0, 16.0)

const DIRS = [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]
const QUADS = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1)]


static func rotate_dir(dir: Vector2i, rot: int) -> Vector2i:
	assert(dir in DIRS)
	return DIRS[posmod(DIRS.find(dir) + rot, 4)]


static func dir_to_rot(dir: Vector2i) -> int:
	assert(dir in DIRS)
	return DIRS.find(dir)


static func rot_to_dir(rot: int) -> Vector2i:
	return DIRS[posmod(rot, 4)]


static func rot_to_quad(rot: int) -> Vector2i:
	return QUADS[posmod(rot, 4)]


static func quad_to_rot(quad: Vector2i) -> int:
	assert(quad in QUADS)
	return QUADS.find(quad)
