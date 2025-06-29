extends Node
class_name GameActionManager

## Gestor de acciones para juego estilo Civilization
## 
## Este script se encarga de:
## - Recibir señales del MapManager sobre interacciones con tiles
## - Determinar qué acciones realizar basado en el contexto del juego
## - Manejar selección de tiles, construcción, movimiento de unidades, etc.
## - Mantener el estado del juego (turno actual, recursos, etc.)
## - Coordinar con MapVisualizer para mostrar estados visuales

## Señales para comunicar cambios de estado
signal tile_selection_changed(selected_tile_id: String, tile_data: Dictionary)
signal action_executed(action_type: String, result: Dictionary)
signal game_state_changed(new_state: Dictionary)

## Estados del juego
enum GameMode {
	EXPLORATION, # Exploración del mapa
	BUILDING, # Modo construcción
	UNIT_MOVEMENT, # Movimiento de unidades
	COMBAT, # Combate
	DIPLOMACY # Diplomacia
}

enum ActionType {
	SELECT_TILE,
	BUILD_STRUCTURE,
	MOVE_UNIT,
	ATTACK,
	EXPLORE_AREA,
	SHOW_INFO
}

## Variables de estado
var current_game_mode: GameMode = GameMode.EXPLORATION
var selected_tile_id: String = ""
var current_player: int = 1
var turn_number: int = 1

## Referencias
var map_manager: MapManager
var map_visualizer: MapVisualizer
var ui_manager: Node # Para futuras notificaciones de UI

## Datos del juego
var player_resources: Dictionary = {}
var tile_buildings: Dictionary = {} # tile_id -> Array[Building]
var tile_units: Dictionary = {} # tile_id -> Array[Unit]


func _ready():
	# Inicializar recursos del jugador
	player_resources = {
		"food": 10,
		"production": 5,
		"science": 0,
		"culture": 0,
		"gold": 25
	}

## Conecta este gestor con el MapManager
func setup(manager: MapManager) -> void:
	map_manager = manager
	map_visualizer = map_manager.get_visualizer()
	
	# Conectar señales del MapManager
	map_manager.tile_selected.connect(_on_tile_selected)
	map_manager.tile_hovered.connect(_on_tile_hovered)
	map_manager.tile_right_clicked.connect(_on_tile_right_clicked)
	map_manager.tile_interaction_requested.connect(_on_tile_interaction_requested)
	map_manager.action_requested.connect(_on_action_requested)
	
	print("GameActionManager configurado y conectado al MapManager")

## Maneja la selección de un tile
func _on_tile_selected(tile_id: String, tile_data: Dictionary, click_type: String) -> void:
	print("GameActionManager: Tile seleccionado - ", tile_id, " (", click_type, ")")
	
	# Actualizar selección
	_update_tile_selection(tile_id, tile_data)
	
	# Limpiar estados visuales anteriores
	if map_visualizer:
		map_visualizer.clear_action_states()
	
	# Determinar acción basada en el modo de juego actual
	match current_game_mode:
		GameMode.EXPLORATION:
			_handle_exploration_click(tile_id, tile_data, click_type)
		GameMode.BUILDING:
			_handle_building_click(tile_id, tile_data, click_type)
		GameMode.UNIT_MOVEMENT:
			_handle_unit_movement_click(tile_id, tile_data, click_type)
		GameMode.COMBAT:
			_handle_combat_click(tile_id, tile_data, click_type)

## Maneja el hover sobre un tile
func _on_tile_hovered(tile_id: String, tile_data: Dictionary) -> void:
	# Mostrar información del tile en UI (futuro)
	_show_tile_preview(tile_id, tile_data)

## Maneja el clic derecho en un tile
func _on_tile_right_clicked(tile_id: String, tile_data: Dictionary) -> void:
	print("GameActionManager: Clic derecho en tile - ", tile_id)
	# Mostrar menú contextual (futuro)
	_show_context_menu(tile_id, tile_data)

## Maneja solicitudes de interacción específicas
func _on_tile_interaction_requested(tile_id: String, tile_data: Dictionary, action_type: String) -> void:
	print("GameActionManager: Interacción solicitada - ", action_type, " en ", tile_id)
	_execute_specific_action(tile_id, tile_data, action_type)

## Maneja solicitudes de acciones generales
func _on_action_requested(action_data: Dictionary) -> void:
	print("GameActionManager: Acción general solicitada - ", action_data)
	_execute_general_action(action_data)

## Actualiza la selección de tiles
func _update_tile_selection(tile_id: String, tile_data: Dictionary) -> void:
	selected_tile_id = tile_id
	
	# Emitir señal de cambio de selección
	tile_selection_changed.emit(tile_id, tile_data)

## Maneja clics en modo exploración
func _handle_exploration_click(tile_id: String, tile_data: Dictionary, _click_type: String) -> void:
	print("Explorando tile: ", tile_id, " tipo: ", tile_data.get("type", "unknown"))
	
	# Mostrar información del tile
	_show_tile_info(tile_id, tile_data)
	
	# Mostrar recursos disponibles en tiles cercanos
	_show_nearby_resources(tile_id)

## Maneja clics en modo construcción
func _handle_building_click(tile_id: String, tile_data: Dictionary, _click_type: String) -> void:
	print("Modo construcción en tile: ", tile_id)
	
	# Verificar si se puede construir en este tile
	if _can_build_on_tile(tile_id, tile_data):
		_show_building_options(tile_id, tile_data)
		_highlight_buildable_tiles(tile_id)
	else:
		print("No se puede construir en este tile")
		_highlight_invalid_tiles([tile_data["node"]])

## Maneja clics en modo movimiento de unidades
func _handle_unit_movement_click(tile_id: String, tile_data: Dictionary, _click_type: String) -> void:
	print("Movimiento de unidad hacia tile: ", tile_id)
	
	# Si hay unidades en el tile seleccionado, mostrar rango de movimiento
	if tile_units.has(tile_id):
		_show_movement_range(tile_id)
	else:
		# Si es un tile válido para mover, calcular ruta
		if _can_move_to_tile(tile_id, tile_data):
			_plan_unit_movement(tile_id, tile_data)
		else:
			_highlight_invalid_tiles([tile_data["node"]])

## Maneja clics en modo combate
func _handle_combat_click(tile_id: String, _tile_data: Dictionary, _click_type: String) -> void:
	print("Acción de combate en tile: ", tile_id)
	
	# Si hay unidades en el tile, mostrar rango de ataque
	if tile_units.has(tile_id):
		_show_attack_range(tile_id)

## ===== MÉTODOS DE VISUALIZACIÓN =====

## Muestra el rango de movimiento para unidades en un tile
func _show_movement_range(tile_id: String) -> void:
	if not map_visualizer:
		return
	
	# Obtener tiles dentro del rango de movimiento (ejemplo: radio de 3)
	var movement_tiles = _get_tiles_in_range(tile_id, 3)
	var valid_movement_tiles = []
	
	for tile_data in movement_tiles:
		if _can_move_to_tile("", tile_data):
			valid_movement_tiles.append(tile_data["node"])
	
	# Aplicar estado visual
	map_visualizer.set_tiles_state(valid_movement_tiles, MapVisualizer.TileState.MOVEMENT_RANGE)

## Muestra el rango de ataque para unidades en un tile
func _show_attack_range(tile_id: String) -> void:
	if not map_visualizer:
		return
	
	# Obtener tiles dentro del rango de ataque (ejemplo: radio de 2)
	var attack_tiles = _get_tiles_in_range(tile_id, 2)
	var valid_attack_tiles = []
	
	for tile_data in attack_tiles:
		valid_attack_tiles.append(tile_data["node"])
	
	# Aplicar estado visual
	map_visualizer.set_tiles_state(valid_attack_tiles, MapVisualizer.TileState.ATTACK_RANGE)

## Resalta tiles donde se puede construir
func _highlight_buildable_tiles(tile_id: String) -> void:
	if not map_visualizer:
		return
	
	# Obtener tiles cercanos donde se puede construir
	var nearby_tiles = _get_tiles_in_range(tile_id, 2)
	var buildable_tiles = []
	
	for tile_data in nearby_tiles:
		if _can_build_on_tile("", tile_data):
			buildable_tiles.append(tile_data["node"])
	
	# Aplicar estado visual
	map_visualizer.set_tiles_state(buildable_tiles, MapVisualizer.TileState.BUILD_AVAILABLE)

## Resalta tiles no válidos para acciones
func _highlight_invalid_tiles(tiles: Array) -> void:
	if not map_visualizer:
		return
	
	map_visualizer.set_tiles_state(tiles, MapVisualizer.TileState.INVALID_ACTION)

## Muestra recursos en tiles cercanos
func _show_nearby_resources(tile_id: String) -> void:
	if not map_visualizer:
		return
	
	# Obtener tiles con recursos cerca
	var resource_tiles = _get_tiles_with_resources(tile_id, 4)
	var resource_tile_nodes = []
	
	for tile_data in resource_tiles:
		resource_tile_nodes.append(tile_data["node"])
	
	# Aplicar estado visual
	map_visualizer.set_tiles_state(resource_tile_nodes, MapVisualizer.TileState.RESOURCE_VIEW)

## ===== MÉTODOS DE LÓGICA DE JUEGO =====

## Obtiene tiles en un rango específico desde un tile
func _get_tiles_in_range(tile_id: String, distance: int) -> Array:
	if not map_manager:
		return []
	
	# Usar el sistema de grafo para obtener tiles en rango
	var graph = map_manager.get_graph()
	return graph.get_nodes_within_distance(tile_id, distance)

## Obtiene tiles con recursos en un rango
func _get_tiles_with_resources(tile_id: String, distance: int) -> Array:
	var tiles_in_range = _get_tiles_in_range(tile_id, distance)
	var resource_tiles = []
	
	for tile_data in tiles_in_range:
		# Verificar si el tile tiene recursos (lógica personalizable)
		if _tile_has_resources(tile_data):
			resource_tiles.append(tile_data)
	
	return resource_tiles

## Verifica si un tile tiene recursos
func _tile_has_resources(tile_data: Dictionary) -> bool:
	# Lógica ejemplo - personalizar según necesidades
	var tile_type = tile_data.get("type", -1)
	return tile_type in [MapManager.BIOME_TYPE.MOUNTAIN, MapManager.BIOME_TYPE.FOREST]

## Verifica si se puede construir en un tile
func _can_build_on_tile(_tile_id: String, tile_data: Dictionary) -> bool:
	# Lógica básica - se puede construir en la mayoría de tiles excepto agua
	var tile_type = tile_data.get("type", -1)
	return tile_type != MapManager.BIOME_TYPE.WATER

## Verifica si se puede mover a un tile
func _can_move_to_tile(_tile_id: String, tile_data: Dictionary) -> bool:
	# Lógica básica de movimiento
	var tile_type = tile_data.get("type", -1)
	return tile_type != MapManager.BIOME_TYPE.WATER

## Muestra información de un tile
func _show_tile_info(tile_id: String, tile_data: Dictionary) -> void:
	print("=== INFORMACIÓN DEL TILE ===")
	print("ID: ", tile_id)
	print("Tipo: ", tile_data.get("type", "unknown"))
	print("Posición: ", tile_data.get("position", Vector3.ZERO))
	print("Coordenadas: ", tile_data.get("coord", Vector2.ZERO))
	
	# Emitir señal de acción ejecutada
	action_executed.emit("show_info", {"tile_id": tile_id, "success": true})
	
	# Información de recursos (futuro)
	# Información de edificios
	if tile_buildings.has(tile_id):
		print("Edificios: ", tile_buildings[tile_id].size())
	
	# Información de unidades
	if tile_units.has(tile_id):
		print("Unidades: ", tile_units[tile_id].size())

## Muestra preview de tile al hacer hover
func _show_tile_preview(_tile_id: String, _tile_data: Dictionary) -> void:
	# Implementar UI de preview (futuro)
	pass

## Muestra menú contextual
func _show_context_menu(tile_id: String, _tile_data: Dictionary) -> void:
	# Implementar menú contextual (futuro)
	print("Menú contextual para tile: ", tile_id)

## Ejecuta una acción específica
func _execute_specific_action(tile_id: String, tile_data: Dictionary, action_type: String) -> void:
	match action_type:
		"build":
			_start_building(tile_id, tile_data)
		"move":
			_start_unit_movement(tile_id, tile_data)
		"attack":
			_start_combat(tile_id, tile_data)
		_:
			print("Acción no reconocida: ", action_type)

## Ejecuta una acción general
func _execute_general_action(action_data: Dictionary) -> void:
	var action_type = action_data.get("type", "")
	match action_type:
		"end_turn":
			_end_turn()
		"save_game":
			_save_game()
		_:
			print("Acción general no reconocida: ", action_type)

## ===== MÉTODOS DE ACCIÓN =====

## Inicia construcción
func _start_building(_tile_id: String, _tile_data: Dictionary) -> void:
	current_game_mode = GameMode.BUILDING
	print("Iniciando modo construcción")
	_change_game_mode(GameMode.BUILDING)

## Inicia movimiento de unidad
func _start_unit_movement(_tile_id: String, _tile_data: Dictionary) -> void:
	current_game_mode = GameMode.UNIT_MOVEMENT
	print("Iniciando modo movimiento")
	_change_game_mode(GameMode.UNIT_MOVEMENT)

## Inicia combate
func _start_combat(_tile_id: String, _tile_data: Dictionary) -> void:
	current_game_mode = GameMode.COMBAT
	print("Iniciando modo combate")
	_change_game_mode(GameMode.COMBAT)

## Muestra opciones de construcción
func _show_building_options(tile_id: String, _tile_data: Dictionary) -> void:
	print("Opciones de construcción para tile: ", tile_id)
	# Implementar UI de construcción (futuro)

## Planifica movimiento de unidad
func _plan_unit_movement(tile_id: String, _tile_data: Dictionary) -> void:
	print("Planificando movimiento hacia: ", tile_id)
	# Implementar pathfinding (futuro)

## Cambia el modo de juego
func _change_game_mode(new_mode: GameMode) -> void:
	var old_mode = current_game_mode
	current_game_mode = new_mode
	
	# Limpiar estados visuales al cambiar modo
	if map_visualizer:
		map_visualizer.clear_action_states()
	
	print("Modo de juego cambiado de ", old_mode, " a ", new_mode)
	
	# Emitir cambio de estado
	game_state_changed.emit({
		"game_mode": current_game_mode,
		"selected_tile": selected_tile_id,
		"turn": turn_number,
		"player": current_player
	})

## Termina el turno
func _end_turn() -> void:
	turn_number += 1
	print("Turno terminado. Nuevo turno: ", turn_number)
	
	# Limpiar estados visuales al terminar turno
	if map_visualizer:
		map_visualizer.clear_action_states()
	
	# Lógica de fin de turno (producción, crecimiento, etc.)
	_process_turn_end()

## Procesa eventos de fin de turno
func _process_turn_end() -> void:
	# Generar recursos
	# Procesar crecimiento de ciudades
	# Mover unidades automáticas
	# etc.
	pass

## Guarda el juego
func _save_game() -> void:
	print("Guardando juego...")
	# Implementar sistema de guardado (futuro)

## ===== MÉTODOS PÚBLICOS =====

## Cambia el modo de juego desde otros scripts
func set_game_mode(mode: GameMode) -> void:
	_change_game_mode(mode)

## Obtiene el tile actualmente seleccionado
func get_selected_tile() -> String:
	return selected_tile_id

## Obtiene el estado actual del juego
func get_game_state() -> Dictionary:
	return {
		"game_mode": current_game_mode,
		"selected_tile": selected_tile_id,
		"turn": turn_number,
		"player": current_player,
		"resources": player_resources
	}

## Solicita una acción específica en un tile (método público)
func request_tile_action(tile_id: String, action: String, data: Dictionary = {}) -> void:
	if map_manager:
		map_manager.request_tile_action(tile_id, action, data)

## Solicita una acción general del juego (método público)
func request_game_action(action_data: Dictionary) -> void:
	if map_manager:
		map_manager.request_game_action(action_data)
