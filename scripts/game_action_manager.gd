extends Node
class_name GameActionManager

## Gestor de acciones para juego estilo Civilization
## 
## Este script se encarga de:
## - Recibir señales del MapManager sobre interacciones con tiles
## - Determinar qué acciones realizar basado en el contexto del juego
## - Manejar selección de tiles, construcción, movimiento de unidades, etc.
## - Mantener el estado del juego (turno actual, recursos, etc.)

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
var selected_tiles: Array[String] = []
var current_player: int = 1
var turn_number: int = 1

## Referencias
var map_manager: MapManager
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
	var previous_selection = selected_tile_id
	selected_tile_id = tile_id
	
	# Limpiar selecciones múltiples si no está en modo apropiado
	if current_game_mode != GameMode.UNIT_MOVEMENT:
		selected_tiles.clear()
	
	selected_tiles.append(tile_id)
	
	# Emitir señal de cambio de selección
	tile_selection_changed.emit(tile_id, tile_data)
	
	# Actualizar visualización
	#if map_manager and map_manager.get_visualizer():
	#	map_manager.get_visualizer().highlight_tile(tile_data["node"])
		
		# Limpiar highlight anterior si existe
	#	if previous_selection != "" and previous_selection != tile_id:
	#		var prev_data = map_manager.get_tile_data(previous_selection)
	#		if prev_data:
	#			map_manager.get_visualizer().clear_highlight(prev_data["node"])

## Maneja clics en modo exploración
func _handle_exploration_click(tile_id: String, tile_data: Dictionary, click_type: String) -> void:
	print("Explorando tile: ", tile_id, " tipo: ", tile_data.get("type", "unknown"))
	
	# Mostrar información del tile
	_show_tile_info(tile_id, tile_data)
	
	# Si hay unidades o edificios, mostrar también su información
	if tile_buildings.has(tile_id):
		print("Edificios en este tile: ", tile_buildings[tile_id])
	
	if tile_units.has(tile_id):
		print("Unidades en este tile: ", tile_units[tile_id])

## Maneja clics en modo construcción
func _handle_building_click(tile_id: String, tile_data: Dictionary, click_type: String) -> void:
	print("Modo construcción en tile: ", tile_id)
	
	# Verificar si se puede construir en este tile
	if _can_build_on_tile(tile_id, tile_data):
		_show_building_options(tile_id, tile_data)
	else:
		print("No se puede construir en este tile")

## Maneja clics en modo movimiento de unidades
func _handle_unit_movement_click(tile_id: String, tile_data: Dictionary, click_type: String) -> void:
	print("Movimiento de unidad hacia tile: ", tile_id)
	
	# Lógica de pathfinding y movimiento (futuro)
	if _can_move_to_tile(tile_id, tile_data):
		_plan_unit_movement(tile_id, tile_data)
	else:
		print("No se puede mover a este tile")

## Maneja clics en modo combate
func _handle_combat_click(tile_id: String, tile_data: Dictionary, click_type: String) -> void:
	print("Acción de combate en tile: ", tile_id)
	# Lógica de combate (futuro)

## Muestra información de un tile
func _show_tile_info(tile_id: String, tile_data: Dictionary) -> void:
	print("=== INFORMACIÓN DEL TILE ===")
	print("ID: ", tile_id)
	print("Tipo: ", tile_data.get("type", "unknown"))
	print("Posición: ", tile_data.get("position", Vector3.ZERO))
	print("Coordenadas: ", tile_data.get("coord", Vector2.ZERO))
	
	# Información de recursos (futuro)
	# Información de edificios
	if tile_buildings.has(tile_id):
		print("Edificios: ", tile_buildings[tile_id].size())
	
	# Información de unidades
	if tile_units.has(tile_id):
		print("Unidades: ", tile_units[tile_id].size())

## Muestra preview de tile al hacer hover
func _show_tile_preview(tile_id: String, tile_data: Dictionary) -> void:
	# Implementar UI de preview (futuro)
	pass

## Muestra menú contextual
func _show_context_menu(tile_id: String, tile_data: Dictionary) -> void:
	# Implementar menú contextual (futuro)
	print("Menú contextual para tile: ", tile_id)

## Ejecuta una acción específica
func _execute_specific_action(tile_id: String, tile_data: Dictionary, action_type: String) -> void:
	match action_type:
		"explore":
			_handle_exploration_click(tile_id, tile_data, "programmatic")
		"build":
			current_game_mode = GameMode.BUILDING
			_handle_building_click(tile_id, tile_data, "programmatic")
		"move_unit":
			current_game_mode = GameMode.UNIT_MOVEMENT
			_handle_unit_movement_click(tile_id, tile_data, "programmatic")
		"show_info":
			_show_tile_info(tile_id, tile_data)

## Ejecuta una acción general
func _execute_general_action(action_data: Dictionary) -> void:
	var action_type = action_data.get("type", "")
	
	match action_type:
		"change_mode":
			var new_mode = action_data.get("mode", GameMode.EXPLORATION)
			_change_game_mode(new_mode)
		"end_turn":
			_end_turn()
		"save_game":
			_save_game()

## Cambia el modo de juego
func _change_game_mode(new_mode: GameMode) -> void:
	var old_mode = current_game_mode
	current_game_mode = new_mode
	
	print("Modo de juego cambiado de ", old_mode, " a ", new_mode)
	
	# Emitir cambio de estado
	game_state_changed.emit({
		"game_mode": current_game_mode,
		"selected_tile": selected_tile_id,
		"turn": turn_number,
		"player": current_player
	})

## Verifica si se puede construir en un tile
func _can_build_on_tile(tile_id: String, tile_data: Dictionary) -> bool:
	# Lógica básica - se puede construir en la mayoría de tiles excepto agua
	var tile_type = tile_data.get("type", -1)
	return tile_type != MapManager.BIOME_TYPE.WATER

## Verifica si se puede mover a un tile
func _can_move_to_tile(tile_id: String, tile_data: Dictionary) -> bool:
	# Lógica básica de movimiento
	return true

## Muestra opciones de construcción
func _show_building_options(tile_id: String, tile_data: Dictionary) -> void:
	print("Opciones de construcción para tile: ", tile_id)
	# Implementar UI de construcción (futuro)

## Planifica movimiento de unidad
func _plan_unit_movement(tile_id: String, tile_data: Dictionary) -> void:
	print("Planificando movimiento hacia: ", tile_id)
	# Implementar pathfinding (futuro)

## Termina el turno
func _end_turn() -> void:
	turn_number += 1
	print("Turno terminado. Nuevo turno: ", turn_number)
	
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

## Métodos públicos para interactuar desde otros scripts

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
		"selected_tiles": selected_tiles,
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
