@tool
extends Sprite2D
class_name ItemSprite

const FRAMERATE = 500.0

@onready var mesh: MeshInstance3D = $SubViewport/Mesh

var item: Item: set = set_item

var _t: float = 0.0


func _ready() -> void:
	_update()


func _process(delta: float) -> void:
	_t += delta
	var st = snappedf(_t, 1.0 / FRAMERATE)
	#mesh.rotation.z = sin(st) * 25.0
	mesh.rotation.y = cos(st * 0.9) * 4.0


func set_item(v: Item) -> void:
	if item == v: return
	item = v
	if is_inside_tree():
		_update()


func _update() -> void:
	if item == null:
		mesh.mesh = null
		visible = false
		set_process(false)
	else:
		mesh.mesh = item.mesh
		visible = true
		set_process(true)
