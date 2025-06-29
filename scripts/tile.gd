extends Node3D
class_name Tile

enum BIOME_TYPE {
	BASE,
	# terreno de bosuqe
	FOREST,
	# terreno de montaña
	MOUNTAIN,
	# terreno de agua
	WATER,
	# terreno de desierto
	DESERT,
	# terreno de pastizal
	GRASS,
}

@export var q: int = 0
@export var r: int = 0
@export var type: BIOME_TYPE = BIOME_TYPE.BASE