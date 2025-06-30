extends Node
class_name EntityManager

## Gestor centralizado de unidades para el sistema de mapas hexagonales.
##
## Esta clase gestiona únicamente unidades, manteniendo una API simple y escalable:
## - Registro de unidades desde editor y runtime
## - Consultas por tile y jugador
## - Movimiento entre tiles

signal entity_added(entity_id: String, entity_data: Dictionary)
signal entity_removed(entity_id: String, entity_data: Dictionary)
signal entity_moved(entity_id: String, from_tile: String, to_tile: String)


## Estructura central de datos
## entity_id -> { type, subtype, tile_id, player_id, data, node }
var entities: Dictionary = {}

## Índices para consultas rápidas
var entities_by_tile: Dictionary = {} # tile_id -> [entity_ids]
var entities_by_player: Dictionary = {} # player_id -> [entity_ids]

## Referencias del sistema
var map_manager: MapManager
var next_entity_id: int = 1

## ===== INICIALIZACIÓN =====

func initialize(map_mgr: MapManager) -> void:
	map_manager = map_mgr
	
	# Conectar señales del mapa para sincronización
	if map_manager:
		map_manager.map_loaded.connect(_on_map_loaded)
	
	print("EntityManager inicializado")

## ===== API PÚBLICA - CREACIÓN DE UNIDADES =====

## Crea una nueva unidad
func create_unit(unit_type: Constants.UnitType, tile_id: String, player_id: int) -> String:
	var entity_id = _generate_entity_id("unit")
	
	var entity_info = {
		"type": "unit",
		"subtype": unit_type,
		"tile_id": tile_id,
		"player_id": player_id,
		"health": 100,
		"movement": 2,
		"attack": 10,
		"defense": 8,
		"node": null
	}
	
	return _add_entity(entity_id, entity_info)

## Registra una unidad existente (desde editor)
func register_entity(entity_node: Node, tile_id: String, player_id: int = 1) -> String:
	var entity_id = _generate_entity_id("registered")
	
	# Determinar tipo basado en el nodo
	var subtype = Constants.UnitType.INFANTRY
	if entity_node.has_method("get_unit_type"):
		subtype = entity_node.get_unit_type()
	
	var entity_info = {
		"type": "unit",
		"subtype": subtype,
		"tile_id": tile_id,
		"player_id": player_id,
		"health": entity_node.get("health") if entity_node.has_method("get") else 100,
		"movement": entity_node.get("movement") if entity_node.has_method("get") else 2,
		"attack": entity_node.get("attack") if entity_node.has_method("get") else 10,
		"defense": entity_node.get("defense") if entity_node.has_method("get") else 8,
		"node": entity_node
	}
	
	return _add_entity(entity_id, entity_info)

## ===== API PÚBLICA - CONSULTAS =====

## Obtiene unidades en un tile
func get_units_in_tile(tile_id: String) -> Array:
	var entity_ids = entities_by_tile.get(tile_id, [])
	var result = []
	for entity_id in entity_ids:
		if entities.has(entity_id):
			result.append(entities[entity_id])
	return result

## Obtiene unidades de un jugador
func get_player_units(player_id: int) -> Array:
	var entity_ids = entities_by_player.get(player_id, [])
	var result = []
	for entity_id in entity_ids:
		if entities.has(entity_id):
			result.append(entities[entity_id])
	return result

## Obtiene datos de una entidad específica
func get_entity(entity_id: String) -> Dictionary:
	return entities.get(entity_id, {})

## ===== API PÚBLICA - MOVIMIENTO =====

## Mueve una unidad a otro tile
func move_entity(entity_id: String, to_tile_id: String) -> bool:
	if not entities.has(entity_id):
		push_warning("EntityManager: Entidad no encontrada: " + entity_id)
		return false
	
	var entity = entities[entity_id]
	var from_tile_id = entity.tile_id
	
	# Actualizar índices
	_remove_from_tile_index(entity_id, from_tile_id)
	_add_to_tile_index(entity_id, to_tile_id)
	
	# Actualizar datos de la entidad
	entity.tile_id = to_tile_id
	
	# Mover nodo 3D si existe, con posicionamiento distribuido
	if entity.node and map_manager:
		var tile_node = map_manager.get_tile_node(to_tile_id)
		if tile_node:
			var position = _calculate_unit_position_in_tile(to_tile_id, entity_id)
			entity.node.global_transform.origin = position
	
	# Emitir señal
	entity_moved.emit(entity_id, from_tile_id, to_tile_id)
	
	print("Entidad movida: ", entity_id, " de ", from_tile_id, " a ", to_tile_id)
	return true

## Calcula la posición de una unidad específica dentro de un tile
func _calculate_unit_position_in_tile(tile_id: String, entity_id: String) -> Vector3:
	var tile_node = map_manager.get_tile_node(tile_id)
	if not tile_node:
		return Vector3.ZERO
	
	var base_position = tile_node.global_transform.origin + Vector3(0, 1, 0)
	
	# Obtener todas las unidades en el tile
	var units_in_tile = get_units_in_tile(tile_id)
	
	# Si solo hay una unidad, usar posición central
	if units_in_tile.size() <= 1:
		return base_position
	
	# Encontrar el índice de esta unidad específica
	var unit_index = -1
	for i in range(units_in_tile.size()):
		# Buscar por entity_id
		for id in entities:
			if entities[id] == units_in_tile[i] and id == entity_id:
				unit_index = i
				break
		if unit_index != -1:
			break
	
	# Si no se encuentra, usar posición central
	if unit_index == -1:
		return base_position
	
	# Calcular offset básico según el número de unidades
	var offset = _get_unit_offset(unit_index, units_in_tile.size())
	return base_position + offset

## Obtiene el offset para una unidad según su índice y total de unidades
func _get_unit_offset(unit_index: int, total_units: int) -> Vector3:
	match total_units:
		1:
			return Vector3.ZERO # Centro
		2:
			return Vector3(-0.5 + (unit_index * 1.0), 0, 0) # Lado a lado, más separadas
		3:
			match unit_index:
				0: return Vector3(-0.5, 0, 0.3) # Izquierda
				1: return Vector3(0.5, 0, 0.3) # Derecha
				2: return Vector3(0, 0, -0.5) # Atrás
		4:
			match unit_index:
				0: return Vector3(-0.5, 0, 0.5) # Izquierda adelante
				1: return Vector3(0.5, 0, 0.5) # Derecha adelante
				2: return Vector3(-0.5, 0, -0.5) # Izquierda atrás
				3: return Vector3(0.5, 0, -0.5) # Derecha atrás
		_:
			# Para más de 4 unidades, distribución circular con mayor radio
			var angle = (unit_index * 2.0 * PI) / total_units
			var radius = 0.6
			return Vector3(cos(angle) * radius, 0, sin(angle) * radius)
	
	# Valor por defecto si no coincide ningún caso
	return Vector3.ZERO

## ===== MÉTODOS PRIVADOS =====

func _add_entity(entity_id: String, entity_info: Dictionary) -> String:
	# Agregar a estructura principal
	entities[entity_id] = entity_info
	
	# Agregar a índices
	_add_to_tile_index(entity_id, entity_info.tile_id)
	_add_to_player_index(entity_id, entity_info.player_id)
	
	# Emitir señal
	entity_added.emit(entity_id, entity_info)
	
	print("Entidad agregada: ", entity_id, " en tile: ", entity_info.tile_id)
	return entity_id

func _generate_entity_id(prefix: String = "entity") -> String:
	var id = prefix + "_" + str(next_entity_id)
	next_entity_id += 1
	return id

func _add_to_tile_index(entity_id: String, tile_id: String) -> void:
	if not entities_by_tile.has(tile_id):
		entities_by_tile[tile_id] = []
	entities_by_tile[tile_id].append(entity_id)

func _add_to_player_index(entity_id: String, player_id: int) -> void:
	if not entities_by_player.has(player_id):
		entities_by_player[player_id] = []
	entities_by_player[player_id].append(entity_id)

func _remove_from_tile_index(entity_id: String, tile_id: String) -> void:
	if entities_by_tile.has(tile_id):
		entities_by_tile[tile_id].erase(entity_id)

func _remove_from_player_index(entity_id: String, player_id: int) -> void:
	if entities_by_player.has(player_id):
		entities_by_player[player_id].erase(entity_id)

## ===== SINCRONIZACIÓN CON MAPA =====

func _on_map_loaded(tile_count: int) -> void:
	print("EntityManager: Mapa cargado, sincronizando unidades desde tiles...")
	_sync_entities_from_tiles()

## Sincroniza unidades desde los tiles (para unidades colocadas en editor)
func _sync_entities_from_tiles() -> void:
	if not map_manager:
		return
	
	var all_tiles = map_manager.get_all_tiles()
	
	for tile_id in all_tiles:
		var tile_data = all_tiles[tile_id]
		var tile_node = tile_data.get("node")
		
		if tile_node and tile_node.has_method("get_entities_from_editor"):
			var editor_entities = tile_node.get_entities_from_editor()
			
			for entity_node in editor_entities:
				register_entity(entity_node, tile_id)

## ===== DEBUG =====

func print_debug_info() -> void:
	print("=== ENTITY MANAGER DEBUG ===")
	print("Total unidades: ", entities.size())
	print("Tiles con unidades: ", entities_by_tile.keys().size())
	print("Jugadores con unidades: ", entities_by_player)
