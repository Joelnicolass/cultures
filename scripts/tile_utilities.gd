extends Node
class_name TileUtilities

## Clase de utilidades para manejar operaciones comunes con tiles en mapas hexagonales.
##
## Esta clase proporciona funcionalidades reutilizables para:
## - Búsqueda y filtrado de tiles
## - Operaciones de transformación y posicionamiento
## - Validaciones y conversiones
## - Animaciones comunes de tiles
##
## Diseñada para ser usada como singleton o instanciada según necesidades del proyecto.

## Encuentra recursivamente todos los nodos de tipo Tile bajo un nodo padre.
##
## @param parent_node: Nodo padre desde donde buscar
## @param tile_class_name: Nombre de la clase del tile a buscar (por defecto "Tile")
## @return: Array con todas las instancias de Tile encontradas
static func find_all_tiles(parent_node: Node, tile_class_name: String = "Tile") -> Array:
	var tiles: Array = []
	_find_tiles_recursive(parent_node, tiles, tile_class_name)
	return tiles

## Función auxiliar recursiva para buscar tiles.
static func _find_tiles_recursive(node: Node, tiles_array: Array, tile_class_name: String) -> void:
	for child in node.get_children():
		if child.get_class() == tile_class_name or child.has_method("get_type"):
			tiles_array.append(child)
		else:
			_find_tiles_recursive(child, tiles_array, tile_class_name)

## Filtra tiles por tipo específico.
##
## @param tiles: Array de tiles a filtrar
## @param tile_type: Tipo de tile a buscar
## @return: Array con tiles del tipo especificado
static func filter_tiles_by_type(tiles: Array, tile_type) -> Array:
	var filtered: Array = []
	for tile in tiles:
		if tile.has_method("get_type") and tile.get_type() == tile_type:
			filtered.append(tile)
		elif tile.get("type") != null and tile.get("type") == tile_type:
			filtered.append(tile)
	return filtered

## Filtra tiles por rango de coordenadas.
##
## @param tiles: Array de tiles a filtrar
## @param min_coord: Coordenada mínima (Vector2)
## @param max_coord: Coordenada máxima (Vector2)
## @return: Array con tiles dentro del rango especificado
static func filter_tiles_by_coordinate_range(tiles: Array, min_coord: Vector2, max_coord: Vector2) -> Array:
	var filtered: Array = []
	for tile in tiles:
		var coord = _get_tile_coordinate(tile)
		if coord != Vector2.ZERO:
			if coord.x >= min_coord.x and coord.x <= max_coord.x and \
			   coord.y >= min_coord.y and coord.y <= max_coord.y:
				filtered.append(tile)
	return filtered

## Obtiene la coordenada de un tile usando diferentes métodos posibles.
static func _get_tile_coordinate(tile) -> Vector2:
	if tile.has_method("get_coordinate"):
		return tile.get_coordinate()
	elif tile.get("coord") != null:
		return tile.get("coord")
	elif tile.get("q") != null and tile.get("r") != null:
		return Vector2(tile.get("q"), tile.get("r"))
	return Vector2.ZERO

## Encuentra el tile más cercano a una posición mundial.
##
## @param tiles: Array de tiles donde buscar
## @param world_position: Posición mundial (Vector3)
## @return: El tile más cercano o null si no hay tiles
static func find_nearest_tile(tiles: Array, world_position: Vector3):
	if tiles.is_empty():
		return null
	
	var nearest_tile = tiles[0]
	var min_distance = world_position.distance_to(nearest_tile.global_transform.origin)
	
	for tile in tiles:
		var distance = world_position.distance_to(tile.global_transform.origin)
		if distance < min_distance:
			min_distance = distance
			nearest_tile = tile
	
	return nearest_tile

## Calcula la distancia entre dos tiles en el grid hexagonal.
##
## @param tile_a: Primer tile
## @param tile_b: Segundo tile
## @return: Distancia en el grid (pasos hexagonales)
static func get_hex_distance(tile_a, tile_b) -> int:
	var coord_a = _get_tile_coordinate(tile_a)
	var coord_b = _get_tile_coordinate(tile_b)
	
	# Conversión de coordenadas offset a axial para cálculo de distancia hexagonal
	var q1 = coord_a.x - (coord_a.y - int(coord_a.y) % 2) / 2
	var r1 = coord_a.y
	var q2 = coord_b.x - (coord_b.y - int(coord_b.y) % 2) / 2
	var r2 = coord_b.y
	
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2

## Anima la escala de un tile con efecto de rebote.
##
## @param tile: Tile a animar
## @param target_scale: Escala objetivo (Vector3)
## @param duration: Duración de la animación en segundos
## @param bounce_intensity: Intensidad del rebote (1.0 - 2.0)
## @return: Tween creado para la animación
static func animate_tile_bounce(tile: Node3D, target_scale: Vector3, duration: float = 0.3, bounce_intensity: float = 1.2) -> Tween:
	if not tile.get_tree():
		return null
	
	var tween = tile.get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Primero escalar más grande
	tween.tween_property(tile, "scale", target_scale * bounce_intensity, duration * 0.6)
	# Luego a la escala objetivo
	tween.tween_property(tile, "scale", target_scale, duration * 0.4)
	
	return tween

## Anima la aparición gradual de múltiples tiles.
##
## @param tiles: Array de tiles a animar
## @param delay_between_tiles: Retraso entre animaciones de tiles
## @param animation_duration: Duración de animación por tile
static func animate_tiles_cascade(tiles: Array, delay_between_tiles: float = 0.05, animation_duration: float = 0.2) -> void:
	for i in range(tiles.size()):
		var tile = tiles[i]
		if tile is Node3D:
			# Comenzar invisible
			var original_scale = tile.scale
			tile.scale = Vector3.ZERO
			
			# Crear animación con retraso
			tile.get_tree().create_timer(i * delay_between_tiles).timeout.connect(
				func(): animate_tile_bounce(tile, original_scale, animation_duration)
			)

## Resetea la escala de múltiples tiles a su valor original.
##
## @param tiles: Array de tiles a resetear
## @param original_scale: Escala original (por defecto Vector3.ONE)
static func reset_tiles_scale(tiles: Array, original_scale: Vector3 = Vector3.ONE) -> void:
	for tile in tiles:
		if tile is Node3D:
			tile.scale = original_scale

## Obtiene tiles vecinos basándose en distancia euclidiana.
##
## @param center_tile: Tile central
## @param all_tiles: Array con todos los tiles disponibles
## @param max_distance: Distancia máxima para considerar vecinos
## @return: Array con tiles vecinos
static func get_neighboring_tiles_by_distance(center_tile, all_tiles: Array, max_distance: float = 2.1) -> Array:
	var neighbors: Array = []
	var center_pos = center_tile.global_transform.origin
	
	for tile in all_tiles:
		if tile != center_tile:
			var distance = center_pos.distance_to(tile.global_transform.origin)
			if distance <= max_distance:
				neighbors.append(tile)
	
	return neighbors

## Valida si un tile tiene las propiedades mínimas requeridas.
##
## @param tile: Tile a validar
## @param required_properties: Array de strings con nombres de propiedades requeridas
## @return: true si el tile es válido, false en caso contrario
static func validate_tile(tile, required_properties: Array = ["type"]) -> bool:
	if not tile:
		return false
	
	for property in required_properties:
		if not tile.has_method("get_" + property) and tile.get(property) == null:
			return false
	
	return true

## Genera un ID único para un tile basado en sus coordenadas.
##
## @param tile: Tile para generar ID
## @param prefix: Prefijo opcional para el ID
## @return: String con ID único
static func generate_tile_id(tile, prefix: String = "tile") -> String:
	var coord = _get_tile_coordinate(tile)
	return prefix + "_" + str(int(coord.x)) + "_" + str(int(coord.y))

## Agrupa tiles por tipo.
##
## @param tiles: Array de tiles a agrupar
## @return: Dictionary con tiles agrupados por tipo
static func group_tiles_by_type(tiles: Array) -> Dictionary:
	var groups: Dictionary = {}
	
	for tile in tiles:
		var tile_type = null
		if tile.has_method("get_type"):
			tile_type = tile.get_type()
		elif tile.get("type") != null:
			tile_type = tile.get("type")
		
		if tile_type != null:
			if not groups.has(tile_type):
				groups[tile_type] = []
			groups[tile_type].append(tile)
	
	return groups