extends StaticBody3D
class_name TileGame

## Tile básico para el sistema hexagonal
##
## Funcionalidades actuales:
## - Tipos de bioma básicos
## - Gestión de unidades desde editor
## - Integración con EntityManager

@onready var collider: CollisionShape3D = $CollisionShape3D


enum BIOME_TYPE {
	BASE,
	FOREST,
	MOUNTAIN,
	WATER,
	DESERT,
	GRASS,
}

## Propiedades del tile
@export var q: int = 0
@export var r: int = 0
@export var type: BIOME_TYPE:
	set(value):
		type = value
		_show_mesh_by_type(value)

## Unidades colocadas desde el editor
@export var editor_units: Array[Node] = []

## Límites básicos
const MAX_UNITS_IN_TILE = 4

func _ready():
	_show_mesh_by_type(type)

## Obtiene unidades del editor para sincronización con EntityManager
func get_entities_from_editor() -> Array:
	return editor_units.duplicate()

## Verifica si el tile puede aceptar más unidades
func can_accept_unit() -> bool:
	return editor_units.size() < MAX_UNITS_IN_TILE

## Limpia las referencias del editor (usado después de sincronización)
func clear_editor_entities() -> void:
	editor_units.clear()

## Muestra el mesh correspondiente al tipo de bioma
func _show_mesh_by_type(biome_type: BIOME_TYPE) -> void:
	var meshes = get_node("Meshes")
	if not meshes:
		return
		
	for mesh in meshes.get_children():
		mesh.visible = false
	
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
