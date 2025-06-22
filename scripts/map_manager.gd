extends Node
class_name MapManager

# Administra el grafo del mapa usando Graph y lógica de vecinos hexagonales.
var graph: Graph
var hex_grid: HexGrid

func _init() -> void:
	# Instancia el grafo y el helper de vecinos
	graph = Graph.new()
	hex_grid = HexGrid.new()

# Construye el grafo a partir de un diccionario de tiles
func build_graph(tiles: Dictionary) -> void:
	# Agregar nodos con su data
	for key in tiles.keys():
		graph.add_node(key, tiles[key])
	# Agregar aristas según vecinos hexagonales
	for key in tiles.keys():
		var coord = tiles[key]["coord"]
		for neighbor in hex_grid.get_neighbors(coord):
			var nk = str(neighbor)
			if tiles.has(nk):
				graph.add_edge(key, nk)
