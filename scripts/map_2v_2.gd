extends Node3D

## Script refactorizado que usa el nuevo sistema de EnhancedMapManager
## para manejar mapas hexagonales de forma más limpia y escalable.

@onready var GRID_NODE = get_node("Grid")
@onready var camera = get_node("Camera3D")

var map_manager: MapManager

func _ready():
	# Inicializar el EnhancedMapManager de forma dinámica
	map_manager = MapManager.new()
	add_child(map_manager)
	
	# Configurar para usar tiles existentes en la escena
	map_manager.generation_mode = map_manager.MapGenerationMode.MANUAL_PLACEMENT
	map_manager.initialize(GRID_NODE, camera)
	
	# Conectar señales para recibir eventos del mapa
	map_manager.tile_clicked.connect(_on_tile_clicked)
	map_manager.tiles_found_by_type.connect(_on_tiles_found_by_type)
	map_manager.map_loaded.connect(_on_map_loaded)
	
	# Generar/cargar el mapa
	map_manager.generate_map()

## Maneja cuando se hace clic en un tile
func _on_tile_clicked(tile, tile_data) -> void:
	print("Clicked on Tile: ", tile.name)
	print("Tile type: ", tile_data.type)
	print("Tile coord: ", tile_data.coord)

## Maneja cuando se encuentran tiles del mismo tipo
func _on_tiles_found_by_type(tile_ids: Array, search_type) -> void:
	print("Found ", tile_ids.size(), " tiles of type ", search_type)
	for tile_id in tile_ids:
		var tile_data = map_manager.get_tile_data(tile_id)
		print("  - ", tile_id, " at ", tile_data.coord)

## Maneja cuando el mapa ha sido cargado
func _on_map_loaded(tile_count: int) -> void:
	print("=== MAPA CARGADO ===")
	print("Total tiles: ", tile_count)
	
	# Obtener información del grafo
	var graph = map_manager.get_graph()
	print("Grafo: ", graph.get_node_count(), " nodos, ", graph.get_edge_count(), " aristas")

## Función para acceder al MapManager desde otros scripts si es necesario
func get_map_manager() -> Node:
	return map_manager
