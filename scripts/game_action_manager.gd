extends Node
class_name GameActionManager

## Gestor de acciones básicas para movimiento de unidades
## 
## Funcionalidades actuales:
## - Selección de tiles 
## - Movimiento básico de unidades
## - Dos modos: Exploración y Movimiento de unidades

## Señales para comunicar cambios de estado
signal tile_selection_changed(selected_tile_id: String, tile_data: Dictionary)
signal action_executed(action_type: String, result: Dictionary)

## Estados del juego (solo los necesarios)
enum GameMode {
	EXPLORATION, # Exploración del mapa
	UNIT_MOVEMENT # Movimiento de unidades
}

## Variables de estado
var current_game_mode: GameMode = GameMode.EXPLORATION
var selected_tile_id: String = ""
var selected_units: Array = [] # Unidades seleccionadas para movimiento
var current_player: int = 1

## Referencias
var map_manager: MapManager
var map_visualizer: MapVisualizer
var entity_manager: EntityManager

func _ready():
	print("GameActionManager inicializado")

## Conecta este gestor con el MapManager y EntityManager
func setup(manager: MapManager, entity_mgr: EntityManager) -> void:
	map_manager = manager
	map_visualizer = map_manager.get_visualizer()
	entity_manager = entity_mgr
	
	# Conectar señales del MapManager
	map_manager.tile_selected.connect(_on_tile_selected)
	
	# Conectar señales del EntityManager
	entity_manager.entity_moved.connect(_on_entity_moved)
	
	print("GameActionManager configurado")

## Maneja la selección de un tile
func _on_tile_selected(tile_id: String, tile_data: Dictionary, click_type: String) -> void:
	# Actualizar selección
	selected_tile_id = tile_id
	tile_selection_changed.emit(tile_id, tile_data)
	
	# Limpiar estados visuales anteriores
	if map_visualizer:
		map_visualizer.clear_action_states()
	
	# Determinar acción basada en el modo de juego actual
	match current_game_mode:
		GameMode.EXPLORATION:
			_handle_exploration_click(tile_id, tile_data)
		GameMode.UNIT_MOVEMENT:
			_handle_unit_movement_click(tile_id, tile_data)

## Maneja clics en modo exploración
func _handle_exploration_click(tile_id: String, tile_data: Dictionary) -> void:
	print("Explorando tile: ", tile_id, " tipo: ", tile_data.get("type", "unknown"))
	
	# Mostrar información básica del tile
	var units_in_tile = entity_manager.get_units_in_tile(tile_id)
	print("Unidades en tile: ", units_in_tile.size())

## Maneja clics en modo movimiento de unidades
func _handle_unit_movement_click(tile_id: String, tile_data: Dictionary) -> void:
	var units_in_tile = entity_manager.get_units_in_tile(tile_id)
	
	if units_in_tile.size() > 0:
		# Tile con unidades - seleccionar para movimiento
		selected_units.clear()
		for unit in units_in_tile:
			if unit.player_id == current_player:
				selected_units.append(unit)
		
		if selected_units.size() > 0:
			print("Unidades seleccionadas para movimiento: ", selected_units.size())
			_show_movement_range(tile_id)
	else:
		# Tile vacío - mover unidades seleccionadas aquí
		if selected_units.size() > 0:
			_execute_unit_movement(tile_id)

## Muestra el rango de movimiento (visual básico)
func _show_movement_range(tile_id: String) -> void:
	if not map_visualizer:
		return
	
	# Obtener tiles vecinos (simplificado)
	var movement_tiles = _get_nearby_tiles(tile_id, 3)
	var valid_tiles = []
	
	for tile_data in movement_tiles:
		valid_tiles.append(tile_data["node"])
	
	# Aplicar estado visual
	map_visualizer.set_tiles_state(valid_tiles, MapVisualizer.TileState.MOVEMENT_RANGE)

## Ejecuta el movimiento de las unidades seleccionadas
func _execute_unit_movement(destination_tile_id: String) -> void:
	print("Moviendo ", selected_units.size(), " unidades a ", destination_tile_id)
	
	var moved_count = 0
	for unit_data in selected_units:
		var entity_id = _get_entity_id_from_unit_data(unit_data)
		if entity_id != "" and entity_manager.move_entity(entity_id, destination_tile_id):
			moved_count += 1
	
	print("Movimiento completado: ", moved_count, " unidades movidas")
	selected_units.clear()
	
	# Limpiar visualización
	if map_visualizer:
		map_visualizer.clear_action_states()

## Obtiene el entity_id de una unidad usando las propiedades del unit_data
func _get_entity_id_from_unit_data(unit_data: Dictionary) -> String:
	var tile_id = unit_data.get("tile_id", "")
	var player_id = unit_data.get("player_id", -1)
	var subtype = unit_data.get("subtype", -1)
	
	if tile_id == "" or player_id == -1:
		return ""
	
	# Buscar en las entidades del EntityManager
	var entities_in_tile = entity_manager.get_units_in_tile(tile_id)
	for entity in entities_in_tile:
		if entity.player_id == player_id and entity.subtype == subtype:
			# Buscar el entity_id correspondiente
			for entity_id in entity_manager.entities:
				if entity_manager.entities[entity_id] == entity:
					return entity_id
	
	return ""

## Obtiene tiles cercanos (simplificado)
func _get_nearby_tiles(tile_id: String, distance: int) -> Array:
	if not map_manager:
		return []
	
	# Usar el sistema de grafo básico
	var graph = map_manager.get_graph()
	return graph.get_nodes_within_distance(tile_id, distance)

## Maneja cuando una entidad se mueve
func _on_entity_moved(entity_id: String, from_tile: String, to_tile: String) -> void:
	print("GameActionManager: Entidad movida - ", entity_id, " de ", from_tile, " a ", to_tile)

## ===== MÉTODOS PÚBLICOS =====

## Cambia el modo de juego
func set_game_mode(mode: GameMode) -> void:
	var old_mode = current_game_mode
	current_game_mode = mode
	
	# Limpiar estados al cambiar modo
	if map_visualizer:
		map_visualizer.clear_action_states()
	selected_units.clear()
	
	print("Modo cambiado de ", old_mode, " a ", mode)

## Obtiene el estado actual básico
func get_game_state() -> Dictionary:
	return {
		"game_mode": current_game_mode,
		"selected_tile": selected_tile_id,
		"player": current_player
	}
