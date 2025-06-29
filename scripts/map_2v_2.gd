extends Node3D

## Script refactorizado que usa el nuevo sistema de MapManager
## con GameActionManager para manejar acciones estilo Civilization.

@onready var GRID_NODE = get_node("Grid")
@onready var camera = get_node("Camera3D")

var map_manager: MapManager
var game_action_manager: GameActionManager

func _ready():
	# Inicializar el MapManager
	map_manager = MapManager.new()
	add_child(map_manager)
	
	# Inicializar el GameActionManager
	game_action_manager = GameActionManager.new()
	add_child(game_action_manager)
	
	# Configurar MapManager para usar tiles existentes en la escena
	map_manager.generation_mode = map_manager.MapGenerationMode.MANUAL_PLACEMENT
	map_manager.initialize(GRID_NODE, camera)
	
	# Conectar GameActionManager con MapManager
	game_action_manager.setup(map_manager)
	
	# Conectar señales específicas del mapa (mantener compatibilidad)
	map_manager.map_loaded.connect(_on_map_loaded)
	map_manager.map_generated.connect(_on_map_generated)
	
	# Conectar señales del GameActionManager para monitorear acciones
	game_action_manager.tile_selection_changed.connect(_on_tile_selection_changed)
	game_action_manager.game_state_changed.connect(_on_game_state_changed)
	game_action_manager.action_executed.connect(_on_action_executed)
	
	# Generar/cargar el mapa
	await map_manager.generate_map()
	
	print("=== SISTEMA INICIALIZADO ===")
	print("MapManager y GameActionManager configurados")
	print("Modo de juego inicial: ", game_action_manager.current_game_mode)

## Maneja cuando se selecciona un tile
func _on_tile_selection_changed(tile_id: String, tile_data: Dictionary) -> void:
	print("=== TILE SELECCIONADO ===")
	print("ID: ", tile_id)
	print("Tipo: ", tile_data.get("type", "unknown"))
	print("Posición: ", tile_data.get("position", Vector3.ZERO))
	print("Modo de juego actual: ", game_action_manager.current_game_mode)

## Maneja cambios en el estado del juego
func _on_game_state_changed(new_state: Dictionary) -> void:
	print("=== ESTADO DEL JUEGO ACTUALIZADO ===")
	print("Modo: ", new_state.get("game_mode", "unknown"))
	print("Turno: ", new_state.get("turn", 0))
	print("Jugador: ", new_state.get("player", 0))
	print("Tile seleccionado: ", new_state.get("selected_tile", "none"))

## Maneja cuando se ejecuta una acción
func _on_action_executed(action_type: String, result: Dictionary) -> void:
	print("=== ACCIÓN EJECUTADA ===")
	print("Tipo: ", action_type)
	print("Resultado: ", result)

## Maneja cuando el mapa ha sido cargado (compatibilidad)
func _on_map_loaded(tile_count: int) -> void:
	print("=== MAPA CARGADO ===")
	print("Total tiles: ", tile_count)
	
	# Obtener información del grafo
	var graph = map_manager.get_graph()
	print("Grafo: ", graph.get_node_count(), " nodos, ", graph.get_edge_count(), " aristas")

## Maneja cuando el mapa ha sido generado (compatibilidad)
func _on_map_generated(tile_count: int) -> void:
	print("=== MAPA GENERADO ===")
	print("Total tiles: ", tile_count)

## Funciones públicas para interactuar desde UI o otros scripts

## Cambia el modo de juego
func set_game_mode(mode: GameActionManager.GameMode) -> void:
	if game_action_manager:
		game_action_manager.set_game_mode(mode)

## Obtiene el estado actual del juego
func get_game_state() -> Dictionary:
	if game_action_manager:
		return game_action_manager.get_game_state()
	return {}

## Solicita una acción específica en un tile
func request_tile_action(tile_id: String, action: String, data: Dictionary = {}) -> void:
	if game_action_manager:
		game_action_manager.request_tile_action(tile_id, action, data)

## Solicita una acción general del juego
func request_game_action(action_data: Dictionary) -> void:
	if game_action_manager:
		game_action_manager.request_game_action(action_data)

## Funciones de utilidad para acceso desde otros scripts

## Acceso al MapManager para compatibilidad
func get_map_manager() -> MapManager:
	return map_manager

## Acceso al GameActionManager
func get_game_action_manager() -> GameActionManager:
	return game_action_manager

## Ejemplos de uso programático (para testing)
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				print("Cambiando a modo EXPLORACIÓN")
				set_game_mode(GameActionManager.GameMode.EXPLORATION)
			KEY_2:
				print("Cambiando a modo CONSTRUCCIÓN")
				set_game_mode(GameActionManager.GameMode.BUILDING)
			KEY_3:
				print("Cambiando a modo MOVIMIENTO DE UNIDADES")
				set_game_mode(GameActionManager.GameMode.UNIT_MOVEMENT)
			KEY_4:
				print("Cambiando a modo COMBATE")
				set_game_mode(GameActionManager.GameMode.COMBAT)
			KEY_SPACE:
				print("Estado actual del juego:")
				print(get_game_state())
			KEY_ENTER:
				print("Terminando turno...")
				request_game_action({"type": "end_turn"})
