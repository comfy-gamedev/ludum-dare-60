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


static func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos) * GRID_PX


static func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i((world_pos / GRID_PX).round())


static func points_in_circle(center: Vector2i, radius: float) -> Array[Vector2i]:
	var result: Array[Vector2i]
	var extent := Vector2i(Vector2(radius, radius).ceil())
	for y in range(0, extent.y + 1):
		for x in range(0, extent.x + 1):
			if Geometry2D.is_point_in_circle(Vector2(x, y), Vector2.ZERO, radius):
				result.append(center + Vector2i(x, y))
				if x != 0:
					result.append(center + Vector2i(-x, y))
				if y != 0:
					result.append(center + Vector2i(x, -y))
				if x != 0 and y != 0:
					result.append(center + Vector2i(-x, -y))
	return result
