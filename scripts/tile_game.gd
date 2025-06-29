@tool
extends StaticBody3D
class_name TileGame

enum BIOME_TYPE {
	BASE, # terreno base
	FOREST, # terreno de bosuqe
	MOUNTAIN, # terreno de montaña
	WATER, # terreno de agua
	DESERT, # terreno de desierto
	GRASS, # terreno de pastizal
}


@onready var collider: CollisionShape3D = $CollisionShape3D

## Propiedades del tile que se usan para creación del grafo
@export var q: int = 0
@export var r: int = 0

## Tipo de bioma del tile -> usado para definir el tipo de terreno que se debe mostrar
@export var type: BIOME_TYPE:
	set(value):
		type = value
		_show_mesh_by_type(value)


func _ready():
	# mostrar el mesh correspondiente al tipo de bioma
	_show_mesh_by_type(type)


### FUNCIONES PÚBLICAS ###
func set_biome_type(biome_type: BIOME_TYPE) -> void:
	type = biome_type
	_show_mesh_by_type(biome_type)


### FUNCIONES PRIVADAS ###

func _show_mesh_by_type(biome_type: BIOME_TYPE) -> void:
	var meshes = get_node("Meshes")
	if not meshes:
		print("No se encontró el nodo 'Meshes'. Asegúrate de que existe en la jerarquía del tile.")
		return
		
	for mesh in meshes.get_children():
		mesh.visible = false

	print("Mostrando mesh para tipo de bioma: ", biome_type)
	
	match biome_type:
		BIOME_TYPE.BASE:
			meshes.get_node("Base").visible = true
		BIOME_TYPE.FOREST:
			meshes.get_node("Forest").visible = true
		BIOME_TYPE.MOUNTAIN:
			meshes.get_node("Rock").visible = true
		BIOME_TYPE.WATER:
			meshes.get_node("Water").visible = true
		BIOME_TYPE.DESERT:
			meshes.get_node("Desert").visible = true
		BIOME_TYPE.GRASS:
			meshes.get_node("Grass").visible = true
		_:
			print("Tipo de bioma desconocido: ", biome_type)
			return
