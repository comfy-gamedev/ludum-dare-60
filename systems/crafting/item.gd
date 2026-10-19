extends Resource
class_name Item

enum Kind {
	UNSPECIFIED,
	WOOD,
	STONE,
	WATER,
	FOOD,
	TREASURE,
}

@export var name: String
@export var mesh: Mesh
@export var kind: Kind = Kind.UNSPECIFIED

var rank: int = -1
