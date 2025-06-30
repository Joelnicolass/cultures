extends Node3D

## Script principal que inicializa el sistema básico de mapa hexagonal con unidades

@onready var GRID_NODE = get_node("Grid")
@onready var camera = get_node("Camera3D")

var map_manager: MapManager
var game_action_manager: GameActionManager
var entity_manager: EntityManager

func _ready():
	# Inicializar componentes
	map_manager = MapManager.new()
	add_child(map_manager)
	
	entity_manager = EntityManager.new()
	add_child(entity_manager)
	
	game_action_manager = GameActionManager.new()
	add_child(game_action_manager)
	
	# Configurar MapManager
	map_manager.generation_mode = map_manager.MapGenerationMode.MANUAL_PLACEMENT
	map_manager.initialize(GRID_NODE, camera)
	
	# Conectar sistemas
	entity_manager.initialize(map_manager)
	game_action_manager.setup(map_manager, entity_manager)
	
	# Conectar señales básicas
	game_action_manager.tile_selection_changed.connect(_on_tile_selection_changed)
	game_action_manager.action_executed.connect(_on_action_executed)
	entity_manager.entity_added.connect(_on_entity_added)
	entity_manager.entity_moved.connect(_on_entity_moved)
	
	# Generar mapa
	await map_manager.generate_map()
	
	print("=== SISTEMA INICIALIZADO ===")
	print("Modo de juego inicial: ", game_action_manager.current_game_mode)
	entity_manager.print_debug_info()

## Maneja la selección de tiles
func _on_tile_selection_changed(tile_id: String, tile_data: Dictionary) -> void:
	print("=== TILE SELECCIONADO ===")
	print("ID: ", tile_id)
	print("Tipo: ", tile_data.get("type", "unknown"))
	print("Modo actual: ", game_action_manager.current_game_mode)

## Maneja acciones ejecutadas
func _on_action_executed(action_type: String, result: Dictionary) -> void:
	print("=== ACCIÓN EJECUTADA ===")
	print("Tipo: ", action_type)
	print("Resultado: ", result)

## Maneja cuando se añade una entidad
func _on_entity_added(entity_id: String, entity_data: Dictionary) -> void:
	print("=== ENTIDAD AÑADIDA ===")
	print("ID: ", entity_id)
	print("Tipo: ", entity_data.get("type"))

## Maneja cuando se mueve una entidad
func _on_entity_moved(entity_id: String, from_tile: String, to_tile: String) -> void:
	print("=== ENTIDAD MOVIDA ===")
	print("ID: ", entity_id)
	print("De: ", from_tile, " a: ", to_tile)

## ===== CONTROLES BÁSICOS =====

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				print("Cambiando a modo EXPLORACIÓN")
				game_action_manager.set_game_mode(GameActionManager.GameMode.EXPLORATION)
			KEY_2:
				print("Cambiando a modo MOVIMIENTO DE UNIDADES")
				game_action_manager.set_game_mode(GameActionManager.GameMode.UNIT_MOVEMENT)
			KEY_SPACE:
				print("Estado actual del juego:")
				print(game_action_manager.get_game_state())

## ===== ACCESO A COMPONENTES =====

func get_map_manager() -> MapManager:
	return map_manager

func get_game_action_manager() -> GameActionManager:
	return game_action_manager

func get_entity_manager() -> EntityManager:
	return entity_manager
