extends Node3D

@onready var GRID_NODE = get_node("Grid")

var MAP = {
	"tiles": {},
}

var graph: Graph
var hex_grid: HexGrid

@onready var camera = get_node("Camera3D")

var debug_marked: Array = []

# Devuelve todos los nodos Tile bajo un nodo dado (recursivo)
func _find_tiles(node: Node, arr: Array) -> void:
	for child in node.get_children():
		if child is Tile:
			arr.append(child)
		else:
			_find_tiles(child, arr)

# Retorna un Array con todas las instancias de Tile bajo GRID_NODE
func _get_all_tiles() -> Array:
	var tiles: Array = []
	_find_tiles(GRID_NODE, tiles)
	return tiles

func _ready():
	graph = Graph.new()
	hex_grid = HexGrid.new()
	
	print("=== GENERANDO MAPA ===")
	# Crear nodos
	for tile in _get_all_tiles():
		# Calcular coordenadas offset y redondear correctamente
		var raw_off = hex_grid.world_to_offset(tile.global_transform.origin)
		var off = Vector2(round(raw_off.x), round(raw_off.y))
		tile.q = int(off.x)
		tile.r = int(off.y)
		var q = tile.q
		var r = tile.r
		# Usar nombre del tile como parte de la clave para evitar colisiones
		var key = tile.name
		var data = {"coord": Vector2(q, r), "node": tile, "type": tile.type, "grid_key": str(q) + "_" + str(r)}
		MAP["tiles"][key] = data
		graph.add_node(key, data)
		print("Procesado: ", tile.name, " -> pos: ", tile.global_transform.origin, " -> key: ", key)
	
	print("=== MAPA FINAL ===")
	print("Total tiles en mapa: ", MAP["tiles"].size())
	
	# Agregar aristas: para cada tile, conectar con vecinos basándose en distancia
	var keys = MAP["tiles"].keys()
	for i in range(keys.size()):
		var key_a = keys[i]
		var pos_a = MAP["tiles"][key_a]["node"].global_transform.origin
		for j in range(i + 1, keys.size()):
			var key_b = keys[j]
			var pos_b = MAP["tiles"][key_b]["node"].global_transform.origin
			# Si la distancia es aproximadamente 2 unidades (vecinos hexagonales)
			if pos_a.distance_to(pos_b) <= 2.1:
				graph.add_edge(key_a, key_b)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		# Usar PhysicsRayQueryParameters3D para intersectar rayos
		var space = get_world_3d().direct_space_state
		var params = PhysicsRayQueryParameters3D.new()
		params.from = from
		params.to = to
		params.exclude = []
		params.collision_mask = 1
		var result = space.intersect_ray(params)
		if result and result.collider:
			var clicked = result.collider
			if clicked is Tile:
				print("Clicked on Tile: ", clicked.name)
				_clear_debug_marks()
				var ttype = clicked.type
				# Usar el nombre del tile como clave
				var clicked_key = clicked.name
				
				print("Clicked key: ", clicked_key, " Direct neighbors: ", graph.get_neighbors_ids(clicked_key))
				var ids = graph.bfs_by_type(clicked_key, ttype)
				print("BFS result IDs: ", ids)
				for id in ids:
					_mark_node(MAP["tiles"][id]["node"])
				_mark_node(clicked)

func _mark_node(node: Node3D) -> void:
	node.scale = Vector3(1.0, 1.2, 1.0)
	debug_marked.append(node)
	print("Marked node: ", node.name)

func _clear_debug_marks() -> void:
	for node in debug_marked:
		node.scale = Vector3(1.0, 1.0, 1.0)
		print("Unmarked node: ", node.name)
	debug_marked.clear()
