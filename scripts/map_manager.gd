extends Node
class_name MapManager

## Clase principal para gestionar mapas hexagonales de forma robusta y escalable.
##
## Esta clase unifica la funcionalidad de generación y manejo de mapas, proporcionando:
## - Generación aleatoria de mapas con ruido
## - Carga de mapas existentes desde nodos en escena
## - Gestión del grafo de conectividad
## - Integración con visualización e interacción
## - Sistema de eventos para interacción con tiles
##
## Diseñada para ser reutilizable en diferentes tipos de proyectos de mapas hexagonales.

signal map_generated(tile_count: int)
signal map_loaded(tile_count: int)

## Señales de interacción con tiles - Diseñadas para juegos de estrategia
signal tile_selected(tile_id: String, tile_data: Dictionary, click_type: String)
signal tile_hovered(tile_id: String, tile_data: Dictionary)
signal tile_right_clicked(tile_id: String, tile_data: Dictionary)
signal tile_interaction_requested(tile_id: String, tile_data: Dictionary, action_type: String)

## Señales para gestión de acciones (futuro uso con edificios/unidades)
signal action_requested(action_data: Dictionary)
signal selection_changed(selected_tiles: Array)

## Enums compartidos
enum MapGenerationMode {
	RANDOM_NOISE, ## Generación usando FastNoiseLite
	MANUAL_PLACEMENT, ## Tiles colocados manualmente en escena
	HYBRID ## Combinación de ambos métodos
}

enum HEX_STATUS {
	EMPTY,
	FULL,
}

enum BIOME_TYPE {
	BASE,
	FOREST,
	MOUNTAIN,
	WATER,
	DESERT,
	GRASS,
}

## Configuración de generación
@export var generation_mode: MapGenerationMode = MapGenerationMode.RANDOM_NOISE
@export var chunk_size: int = 30
@export var tile_size: float = 2.0
@export var neighbor_max_distance: float = 2.1

## Referencias a recursos de tiles
# TODO -> CAMBIAR ESTO POR LAS SCENAS DE TILES - EL BLEND ERA SOLO PARA PRUEBAS, NO TIENE FUNCIONALIDAD MAS ALLA DE LA MALLA 3D
const SCENE_FOR_TILE_TYPE = {
	BIOME_TYPE.BASE: preload("res://resources/blend_files/hex_tile_base.blend"),
	BIOME_TYPE.GRASS: preload("res://resources/blend_files/hex_tile_grass.blend"),
	BIOME_TYPE.MOUNTAIN: preload("res://resources/blend_files/hex_tile_rock.blend"),
	BIOME_TYPE.DESERT: preload("res://resources/blend_files/hex_tile_desert.blend"),
	BIOME_TYPE.FOREST: preload("res://resources/blend_files/hex_tile_forest.blend"),
	BIOME_TYPE.WATER: preload("res://resources/blend_files/hex_tile_water.blend"),
}

## Componentes del sistema
var graph: Graph
var hex_grid: HexGrid
var visualizer: Node # Cambio temporal para evitar problemas de tipo

## Estado del mapa
var map_data: Dictionary = {"tiles": {}}
var grid_node: Node3D
var is_map_ready: bool = false
var auto_setup_camera: bool = true

## Inicializa el MapManager con configuración básica.
##
## @param grid_container: Nodo que contendrá los tiles del mapa
## @param camera: Cámara para interacción (opcional)
## @param auto_camera_setup: Si debe configurar automáticamente la cámara (por defecto true)
func initialize(grid_container: Node3D, camera: Camera3D = null, auto_camera_setup: bool = true) -> void:
	grid_node = grid_container
	auto_setup_camera = auto_camera_setup
	
	# Inicializar componentes
	graph = Graph.new()
	hex_grid = HexGrid.new()
	
	if camera:
		# Crear visualizador de forma dinámica
		var visualizer_script = load("res://scripts/map_visualizer.gd")
		visualizer = visualizer_script.new()
		add_child(visualizer)
		visualizer.setup(camera)
		visualizer.tile_clicked.connect(_on_tile_clicked)

## Genera un mapa usando el modo especificado.
##
## @param mode: Modo de generación a usar (opcional, usa el configurado por defecto)
func generate_map(mode: MapGenerationMode = generation_mode) -> void:
	if not grid_node:
		push_error("MapManager: grid_node no está configurado. Llama a initialize() primero.")
		return
	
	# Solo limpiar el mapa si no es modo manual (para preservar tiles existentes)
	if mode != MapGenerationMode.MANUAL_PLACEMENT:
		clear_map()
	
	match mode:
		MapGenerationMode.RANDOM_NOISE:
			await _generate_random_map()
		MapGenerationMode.MANUAL_PLACEMENT:
			_load_existing_tiles()
		MapGenerationMode.HYBRID:
			await _generate_random_map()
			_load_existing_tiles()
	
	_build_graph()
	is_map_ready = true
	map_generated.emit(map_data["tiles"].size())

## Genera un mapa aleatorio usando ruido.
func _generate_random_map() -> void:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	var noise_texture = noise.get_image(chunk_size, chunk_size)

	print("=== GENERANDO MAPA ALEATORIO ===")
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			var noise_value = noise_texture.get_pixel(x, y).r
			var tile_data = _process_noise_value(noise_value)
			var coord = Vector2(x, y)
			
			# Crear tile
			var tile = SCENE_FOR_TILE_TYPE[tile_data.type].instantiate()
			grid_node.add_child(tile)
			
			# Posicionar tile
			var tile_pos = _calculate_hex_position(coord)
			tile.global_transform.origin = tile_pos
			
			# Configurar tile
			if tile.has_method('set_data'):
				tile.set_data(tile_data)
			
			# Establecer coordenadas hexagonales
			tile.q = x
			tile.r = y
			tile.type = tile_data.type
			
			# Almacenar en mapa
			var tile_id = _generate_tile_id_internal(tile)
			var complete_data = {
				"coord": coord,
				"position": tile_pos,
				"node": tile,
				"type": tile_data.type,
				"status": tile_data.status,
				"grid_key": str(x) + "_" + str(y)
			}
			map_data["tiles"][tile_id] = complete_data
			
			# Animación de aparición
			if tile_data.status != HEX_STATUS.EMPTY:
				_animate_tile_bounce_internal(tile, Vector3.ONE, 0.1 + randf() * 0.1)
			
			# Pequeña pausa para distribución de carga
			if (x * chunk_size + y) % 10 == 0:
				await get_tree().process_frame
	
	_center_map()

## Carga tiles existentes desde la escena.
func _load_existing_tiles() -> void:
	print("=== CARGANDO TILES EXISTENTES ===")
	print("Buscando tiles en: ", grid_node.name)
	print("Hijos directos del grid: ", grid_node.get_child_count())
	
	var existing_tiles = _find_all_tiles_internal(grid_node)
	print("Tiles encontrados: ", existing_tiles.size())
	
	if existing_tiles.is_empty():
		print("ERROR: No se encontraron tiles en la escena")
		return
	
	for tile in existing_tiles:
		print("Procesando tile: ", tile.name)
		print("  - Posición: ", tile.global_transform.origin)
		print("  - Tipo: ", tile.type)
		print("  - q,r: ", tile.q, ",", tile.r)
		print("  - Visible: ", tile.visible)
		print("  - Hijos: ", tile.get_child_count())
		
		# Asegurar que el tile y todos sus hijos sean visibles
		tile.visible = true
		for child in tile.get_children():
			if child.has_method("set_visible"):
				child.visible = true
			print("    - Hijo: ", child.name, " visible: ", child.visible if child.has_method("get_visible") else "N/A")
		
		# Asegurar que el tile tenga un tipo válido
		if tile.name.contains("Base"):
			tile.type = BIOME_TYPE.BASE
		elif tile.name.contains("Grass"):
			tile.type = BIOME_TYPE.GRASS
		elif tile.name.contains("Rock"):
			tile.type = BIOME_TYPE.MOUNTAIN
		elif tile.name.contains("Desert"):
			tile.type = BIOME_TYPE.DESERT
		elif tile.name.contains("Forest"):
			tile.type = BIOME_TYPE.FOREST
		elif tile.name.contains("Water"):
			tile.type = BIOME_TYPE.WATER
		
		# Calcular coordenadas si no las tiene o están en 0,0
		if tile.q == 0 and tile.r == 0 and tile.name != "HexGrass": # HexGrass está en el origen
			var raw_coord = hex_grid.world_to_offset(tile.global_transform.origin)
			tile.q = int(round(raw_coord.x))
			tile.r = int(round(raw_coord.y))
		
		# Generar ID y datos
		var tile_id = tile.name if tile.name != "" else _generate_tile_id_internal(tile)
		var tile_data = {
			"coord": Vector2(tile.q, tile.r),
			"node": tile,
			"type": tile.type,
			"position": tile.global_transform.origin,
			"grid_key": str(tile.q) + "_" + str(tile.r)
		}
		
		map_data["tiles"][tile_id] = tile_data
		print("Tile cargado exitosamente: ", tile_id, " en ", tile_data.coord, " tipo: ", tile_data.type)
	
	print("=== RESUMEN DE CARGA ===")
	print("Total tiles cargados: ", map_data["tiles"].size())
	for tile_id in map_data["tiles"]:
		var data = map_data["tiles"][tile_id]
		print("  - ", tile_id, ": pos=", data.position, " tipo=", data.type)
	
	map_loaded.emit(map_data["tiles"].size())

## Procesa un valor de ruido para determinar el tipo de tile.
##
## @param noise_value: Valor del ruido (0.0 - 1.0)
## @return: Dictionary con datos del tile
func _process_noise_value(noise_value: float) -> Dictionary:
	var tile_type: BIOME_TYPE
	var status = HEX_STATUS.FULL
	
	if noise_value < 0.1:
		tile_type = BIOME_TYPE.BASE
	elif noise_value < 0.5:
		tile_type = BIOME_TYPE.GRASS
	elif noise_value < 0.6:
		tile_type = BIOME_TYPE.MOUNTAIN
	elif noise_value < 0.7:
		tile_type = BIOME_TYPE.DESERT
	elif noise_value < 0.8:
		tile_type = BIOME_TYPE.FOREST
	else:
		tile_type = BIOME_TYPE.WATER
	
	return {
		"type": tile_type,
		"status": status,
		"noise_value": noise_value
	}

## Calcula la posición 3D de un tile basado en coordenadas hexagonales.
##
## @param coord: Coordenadas del tile (Vector2)
## @return: Posición mundial (Vector3)
func _calculate_hex_position(coord: Vector2) -> Vector3:
	var x = coord.x * tile_size * cos(deg_to_rad(30))
	var z = coord.y * tile_size * 0.75
	
	# Offset para filas impares
	if int(coord.y) % 2 == 1:
		x += tile_size * cos(deg_to_rad(30)) / 2
	
	return Vector3(x, 0, z)

## Centra el mapa en el origen.
func _center_map() -> void:
	# Solo centrar el mapa si la configuración automática de cámara está habilitada
	if not auto_setup_camera:
		return
		
	var size_x = chunk_size * tile_size * cos(deg_to_rad(30))
	var size_z = chunk_size * tile_size * 0.75
	var offset = Vector3(-size_x / 2, 0, -size_z / 2)
	
	grid_node.global_transform.origin += offset
	
	# Actualizar posiciones en datos del mapa
	for tile_id in map_data["tiles"]:
		map_data["tiles"][tile_id]["position"] += offset

## Construye el grafo de conectividad entre tiles.
func _build_graph() -> void:
	print("=== CONSTRUYENDO GRAFO ===")
	
	# Agregar nodos
	for tile_id in map_data["tiles"]:
		graph.add_node(tile_id, map_data["tiles"][tile_id])
	
	# Agregar aristas basadas en distancia o vecinos hexagonales
	var tile_ids = map_data["tiles"].keys()
	for i in range(tile_ids.size()):
		var tile_a_id = tile_ids[i]
		var tile_a_data = map_data["tiles"][tile_a_id]
		
		for j in range(i + 1, tile_ids.size()):
			var tile_b_id = tile_ids[j]
			var tile_b_data = map_data["tiles"][tile_b_id]
			
			# Conectar si están dentro del rango de vecinos
			var distance = tile_a_data["position"].distance_to(tile_b_data["position"])
			if distance <= neighbor_max_distance:
				graph.add_edge(tile_a_id, tile_b_id)
	
	print("Grafo construido: ", graph.get_node_count(), " nodos, ", graph.get_edge_count(), " aristas")

## Limpia el mapa actual.
func clear_map() -> void:
	if visualizer:
		visualizer.clear_all()
	
	graph.clear()
	map_data["tiles"].clear()
	
	# Eliminar tiles existentes
	if grid_node:
		for child in grid_node.get_children():
			if child is Tile:
				child.queue_free()
	
	is_map_ready = false

## Maneja el clic en un tile de forma genérica.
## Solo se encarga de identificar el tile y emitir las señales apropiadas.
## La lógica específica de qué hacer se maneja en otros scripts.
func _on_tile_clicked(tile, click_type: String = "left_click") -> void:
	if not is_map_ready:
		return
	
	var tile_id = _find_tile_id(tile)
	if tile_id == "":
		push_warning("MapManager: Tile clickeado no encontrado en el mapa")
		return
	
	var tile_data = map_data["tiles"][tile_id]
	
	# Emitir señal genérica de selección de tile
	tile_selected.emit(tile_id, tile_data, click_type)
	
	# Limpiar visualizaciones anteriores (esto lo mantenemos por compatibilidad)
	if visualizer:
		visualizer.clear_marks()

## Maneja el hover sobre un tile.
func _on_tile_hovered(tile) -> void:
	if not is_map_ready:
		return
	
	var tile_id = _find_tile_id(tile)
	if tile_id == "":
		return
	
	var tile_data = map_data["tiles"][tile_id]
	tile_hovered.emit(tile_id, tile_data)

## Maneja el clic derecho en un tile.
func _on_tile_right_clicked(tile) -> void:
	if not is_map_ready:
		return
	
	var tile_id = _find_tile_id(tile)
	if tile_id == "":
		return
	
	var tile_data = map_data["tiles"][tile_id]
	tile_right_clicked.emit(tile_id, tile_data, "right_click")

## Solicita una acción específica en un tile.
## Útil para cuando se quiere ejecutar una acción programática.
func request_tile_action(tile_id: String, action_type: String, additional_data: Dictionary = {}) -> void:
	if not map_data["tiles"].has(tile_id):
		push_warning("MapManager: Tile ID no válido: " + tile_id)
		return
	
	var tile_data = map_data["tiles"][tile_id].duplicate()
	tile_data.merge(additional_data)
	
	tile_interaction_requested.emit(tile_id, tile_data, action_type)

## Solicita una acción general del juego.
## Para acciones que no están directamente relacionadas con un tile específico.
func request_game_action(action_data: Dictionary) -> void:
	action_requested.emit(action_data)

## Encuentra el ID de un tile en el mapa.
##
## @param tile: Nodo del tile
## @return: ID del tile o string vacío si no se encuentra
func _find_tile_id(tile) -> String:
	for tile_id in map_data["tiles"]:
		if map_data["tiles"][tile_id]["node"] == tile:
			return tile_id
	return ""

## Busca tiles por tipo usando el grafo.
##
## @param tile_type: Tipo de tile a buscar
## @param start_tile_id: ID del tile desde donde comenzar (opcional)
## @return: Array con IDs de tiles del tipo especificado
func find_tiles_by_type(tile_type, start_tile_id: String = "") -> Array:
	if start_tile_id != "":
		return graph.bfs_connected_by_type(start_tile_id, tile_type)
	else:
		# Buscar en todo el grafo
		var found_tiles = []
		for tile_id in map_data["tiles"]:
			if map_data["tiles"][tile_id]["type"] == tile_type:
				found_tiles.append(tile_id)
		return found_tiles

## Obtiene datos de un tile por su ID.
##
## @param tile_id: ID del tile
## @return: Dictionary con datos del tile
func get_tile_data(tile_id: String) -> Dictionary:
	return map_data["tiles"].get(tile_id, {})

## Obtiene el nodo de un tile por su ID.
##
## @param tile_id: ID del tile
## @return: Nodo del tile o null
func get_tile_node(tile_id: String):
	var data = get_tile_data(tile_id)
	return data.get("node", null)

## Obtiene todos los tiles del mapa.
##
## @return: Dictionary con todos los datos de tiles
func get_all_tiles() -> Dictionary:
	return map_data["tiles"]

## Obtiene el grafo de conectividad.
##
## @return: Instancia del grafo
func get_graph() -> Graph:
	return graph

## Obtiene el visualizador del mapa.
##
## @return: Instancia del visualizador
func get_visualizer() -> Node:
	return visualizer

## Verifica si el mapa está listo para usar.
##
## @return: true si el mapa está listo
func is_ready() -> bool:
	return is_map_ready

## Función interna para generar ID de tiles
func _generate_tile_id_internal(tile, prefix: String = "tile") -> String:
	var coord = Vector2.ZERO
	if tile.has_method("get_coordinate"):
		coord = tile.get_coordinate()
	elif tile.get("coord") != null:
		coord = tile.get("coord")
	elif tile.get("q") != null and tile.get("r") != null:
		coord = Vector2(tile.get("q"), tile.get("r"))
	
	return prefix + "_" + str(int(coord.x)) + "_" + str(int(coord.y))

## Función interna para animar tiles
func _animate_tile_bounce_internal(tile: Node3D, target_scale: Vector3, duration: float = 0.3) -> void:
	if not tile.get_tree():
		return
	
	var tween = tile.get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Primero escalar más grande
	tween.tween_property(tile, "scale", target_scale * 1.2, duration * 0.6)
	# Luego a la escala objetivo
	tween.tween_property(tile, "scale", target_scale, duration * 0.4)

## Función interna para encontrar tiles
func _find_all_tiles_internal(parent_node: Node) -> Array:
	var tiles: Array = []
	_find_tiles_recursive_internal(parent_node, tiles)
	return tiles

func _find_tiles_recursive_internal(node: Node, tiles_array: Array) -> void:
	for child in node.get_children():
		# Verificar si es un tile usando diferentes métodos
		var is_tile = false
		
		# Método 1: Verificar si tiene el script tile.gd (es la forma más confiable)
		if child.get_script() != null:
			var script_path = child.get_script().get_path()
			if "tile.gd" in script_path:
				is_tile = true
		
		# Método 2: Verificar si es de la clase Tile
		if child is Tile:
			is_tile = true
		
		# Método 3: Verificar si tiene las propiedades esperadas de un tile
		elif child.has_method("get") and child.get("q") != null and child.get("r") != null and child.get("type") != null:
			is_tile = true
		
		# Método 4: Verificar por nombre del nodo (contiene "Hex")
		elif "Hex" in child.name:
			is_tile = true
		
		if is_tile:
			tiles_array.append(child)
			print("Tile detectado: ", child.name, " - Script: ", child.get_script())
		else:
			_find_tiles_recursive_internal(child, tiles_array)
