@tool
extends StaticBody3D
class_name TileGame

@onready var collider: CollisionShape3D = $CollisionShape3D


## Propiedades del tile que se usan para creación del grafo
@export var q: int = 0
@export var r: int = 0

## Tipo de bioma del tile -> usado para definir el tipo de terreno que se debe mostrar
# -- SE PUEDE USAR EN EL EDITOR -- #
@export var type: Constants.BIOME_TYPE:
	set(value):
		type = value
		_show_mesh_by_type(value)

## Entidades colocadas desde el editor (para configuración inicial)
@export_group("Entities from Editor")
@export var editor_units: Array[Node] = []
@export var editor_buildings: Array[Node] = []

## Configuración de capacidad (para validaciones)
@export_group("Capacity")
@export var MAX_BUILDINGS: int = 5 # cantidad máxima de edificios que se pueden construir en el tile
@export var MAX_UNITS_IN_TILE: int = 5 # cantidad máxima de unidades que se pueden tener en el tile


### FUNCIONES DE ENGINE ###

func _ready():
	# mostrar el mesh correspondiente al tipo de bioma
	_show_mesh_by_type(type)
	
	# En runtime, validar que las entidades del editor estén correctamente configuradas
	if not Engine.is_editor_hint():
		_validate_editor_entities()

### FUNCIONES PÚBLICAS ###

## Setear el tipo de bioma del tile y mostrar el mesh correspondiente
## @param biome_type: Tipo de bioma a establecer
func set_biome_type(biome_type: Constants.BIOME_TYPE) -> void:
	type = biome_type
	_show_mesh_by_type(biome_type)

## Obtiene todas las entidades colocadas desde el editor
## Esta función es llamada por EntityManager para sincronizar
func get_entities_from_editor() -> Array:
	var all_entities = []
	all_entities.append_array(editor_units)
	all_entities.append_array(editor_buildings)
	return all_entities

## Obtiene solo las unidades del editor
func get_editor_units() -> Array:
	return editor_units.duplicate()


## Verifica si el tile puede aceptar más unidades
func can_accept_unit() -> bool:
	# En el nuevo sistema, esto se consulta al EntityManager
	# Esta función se mantiene para compatibilidad local
	return editor_units.size() < MAX_UNITS_IN_TILE


## Limpia las referencias de entidades del editor (usado después de sincronización)
func clear_editor_entities() -> void:
	editor_units.clear()
	editor_buildings.clear()

### FUNCIONES PRIVADAS ###

## Muestra el mesh correspondiente al tipo de bioma del tile
## @param biome_type
func _show_mesh_by_type(biome_type: Constants.BIOME_TYPE) -> void:
	var meshes = get_node("Meshes")
	if not meshes:
		print("No se encontró el nodo 'Meshes'. Asegúrate de que existe en la jerarquía del tile.")
		return
		
	for mesh in meshes.get_children():
		mesh.visible = false

	print("Mostrando mesh para tipo de bioma: ", biome_type)
	
	match biome_type:
		Constants.BIOME_TYPE.BASE:
			meshes.get_node("Base").visible = true
		Constants.BIOME_TYPE.FOREST:
			meshes.get_node("Forest").visible = true
		Constants.BIOME_TYPE.MOUNTAIN:
			meshes.get_node("Rock").visible = true
		Constants.BIOME_TYPE.WATER:
			meshes.get_node("Water").visible = true
		Constants.BIOME_TYPE.DESERT:
			meshes.get_node("Desert").visible = true
		Constants.BIOME_TYPE.GRASS:
			meshes.get_node("Grass").visible = true
		_:
			print("Tipo de bioma desconocido: ", biome_type)
			return

## Valida que las entidades del editor estén correctamente configuradas
func _validate_editor_entities() -> void:
	# Validar unidades
	for i in range(editor_units.size() - 1, -1, -1):
		var unit = editor_units[i]
		if not _is_valid_unit(unit):
			print("WARNING: Unidad inválida en tile ", name, " removiendo: ", unit)
			editor_units.remove_at(i)

	# Validar capacidades
	if editor_units.size() > MAX_UNITS_IN_TILE:
		print("WARNING: Tile ", name, " tiene más unidades de las permitidas (", editor_units.size(), "/", MAX_UNITS_IN_TILE, ")")


## Verifica si un nodo es una unidad válida
func _is_valid_unit(unit_node) -> bool:
	if not unit_node or not is_instance_valid(unit_node):
		return false
	
	# Verificar que tiene las propiedades/métodos esperados de una unidad
	return unit_node.has_method("get_unit_type") or unit_node.has_method("get_entity_type")
