extends Node
class_name Graph

## Clase robusta para manejar grafos no dirigidos con funcionalidades avanzadas de búsqueda y pathfinding.
##
## Esta clase proporciona una implementación completa de un grafo no dirigido que puede ser usado
## para mapas hexagonales, sistemas de navegación, redes de conexiones, etc.
##
## Características principales:
## - Gestión de nodos con datos personalizados
## - Aristas no dirigidas
## - Algoritmos de búsqueda (DFS, BFS)
## - Pathfinding con Dijkstra
## - Búsquedas filtradas por tipo
## - Análisis de conectividad

# Diccionario que contiene los nodos.
# Cada nodo es un diccionario con dos entradas:
#   "data": información asociada al nodo (por ejemplo, datos de un tile)
#   "neighbors": un Array con las claves de los nodos vecinos.
var nodes: Dictionary = {}

## Agrega un nodo al grafo con una clave única y datos opcionales.
## 
## @param node_id: Identificador único del nodo
## @param data: Datos opcionales asociados al nodo (Dictionary, Object, etc.)
func add_node(node_id, data = null) -> void:
	if not nodes.has(node_id):
		nodes[node_id] = {
			"data": data,
			"neighbors": []
		}

## Agrega una arista no dirigida entre dos nodos.
## Si los nodos no existen, los crea automáticamente.
##
## @param node_a: ID del primer nodo
## @param node_b: ID del segundo nodo
func add_edge(node_a, node_b) -> void:
	# Nos aseguramos de que ambos nodos existan
	if not nodes.has(node_a):
		add_node(node_a)
	if not nodes.has(node_b):
		add_node(node_b)
	# Agregar la conexión en ambos sentidos (si no existe ya)
	if not node_b in nodes[node_a]["neighbors"]:
		nodes[node_a]["neighbors"].append(node_b)
	if not node_a in nodes[node_b]["neighbors"]:
		nodes[node_b]["neighbors"].append(node_a)

## Elimina un nodo y todas sus conexiones del grafo.
##
## @param node_id: ID del nodo a eliminar
func remove_node(node_id) -> void:
	if not nodes.has(node_id):
		return
	
	# Eliminar todas las aristas que conectan a este nodo
	for neighbor_id in nodes[node_id]["neighbors"]:
		if nodes.has(neighbor_id):
			nodes[neighbor_id]["neighbors"].erase(node_id)
	
	# Eliminar el nodo
	nodes.erase(node_id)

## Elimina una arista entre dos nodos.
##
## @param node_a: ID del primer nodo
## @param node_b: ID del segundo nodo
func remove_edge(node_a, node_b) -> void:
	if nodes.has(node_a):
		nodes[node_a]["neighbors"].erase(node_b)
	if nodes.has(node_b):
		nodes[node_b]["neighbors"].erase(node_a)

## Verifica si existe un nodo en el grafo.
##
## @param node_id: ID del nodo a verificar
## @return: true si el nodo existe, false en caso contrario
func has_graph_node(node_id) -> bool:
	return nodes.has(node_id)

## Verifica si existe una arista entre dos nodos.
##
## @param node_a: ID del primer nodo
## @param node_b: ID del segundo nodo
## @return: true si existe la arista, false en caso contrario
func has_edge(node_a, node_b) -> bool:
	if not nodes.has(node_a) or not nodes.has(node_b):
		return false
	return node_b in nodes[node_a]["neighbors"]

## Obtiene el número total de nodos en el grafo.
##
## @return: Número de nodos
func get_node_count() -> int:
	return nodes.size()

## Obtiene el número total de aristas en el grafo.
##
## @return: Número de aristas
func get_edge_count() -> int:
	var count = 0
	for node_id in nodes:
		count += nodes[node_id]["neighbors"].size()
	return count / 2 # Dividir por 2 porque las aristas son no dirigidas

## Obtiene todos los IDs de nodos en el grafo.
##
## @return: Array con todos los IDs de nodos
func get_all_node_ids() -> Array:
	return nodes.keys()

# Recorrido en Profundidad (DFS) – se implementa de forma recursiva.
func traverse_dfs(start_node) -> Dictionary:
	var visited: Dictionary = {}
	_dfs_recursive(start_node, visited)
	return visited

func _dfs_recursive(current, visited: Dictionary) -> void:
	if visited.has(current):
		return
	visited[current] = true
	print("Visitando (DFS): ", current)
	# Recorre los vecinos del nodo actual
	for neighbor in nodes[current]["neighbors"]:
		_dfs_recursive(neighbor, visited)

# Recorrido en Anchura (BFS) – se implementa utilizando una cola.
func traverse_bfs(start_node) -> Dictionary:
	var visited: Dictionary = {}
	var queue: Array = []
	
	queue.append(start_node)
	visited[start_node] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		print("Visitando (BFS): ", current)
		for neighbor in nodes[current]["neighbors"]:
			if not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	return visited

# Implementación de Dijkstra para hallar caminos mínimos.
# Si no se especifica target_node, se calculan las distancias mínimas a todos los nodos.
func dijkstra(start_node, target_node = null) -> Dictionary:
	# Valor grande para representar infinito.
	var INF = 1e9
	var distances = {}
	var previous = {}
	var unvisited = []
	
	# Inicializar cada nodo: distancia infinita y sin nodo previo.
	for key in nodes.keys():
		distances[key] = INF
		previous[key] = null
		unvisited.append(key)
	
	# La distancia del nodo inicial es 0.
	distances[start_node] = 0
	
	# Mientras haya nodos sin visitar.
	while unvisited.size() > 0:
		# Buscar el nodo no visitado con la menor distancia.
		var current = unvisited[0]
		for node in unvisited:
			if distances[node] < distances[current]:
				current = node
				
		# Si hemos alcanzado el nodo objetivo, podemos salir temprano.
		if current == target_node:
			break
		
		unvisited.erase(current)
		
		# Para cada vecino, actualizamos la distancia si encontramos un camino más corto.
		for neighbor in nodes[current]["neighbors"]:
			# Solo consideramos vecinos aún no visitados.
			if neighbor in unvisited:
				# Se asume peso = 1 para cada arista.
				var alt = distances[current] + 1
				if alt < distances[neighbor]:
					distances[neighbor] = alt
					previous[neighbor] = current
	
	return {"distances": distances, "previous": previous}

# Función auxiliar que, a partir de los resultados de Dijkstra, reconstruye el camino más corto
# desde start_node hasta target_node. Retorna un Array con las claves que conforman el camino.
func get_shortest_path(start_node, target_node) -> Array:
	var result = dijkstra(start_node, target_node)
	var previous = result["previous"]
	var path = []
	var current = target_node
	
	# Retrocedemos desde el nodo objetivo hasta el nodo inicial.
	while current != null:
		path.insert(0, current)
		current = previous[current]
	
	# Verificamos que efectivamente se alcanzó el nodo de inicio.
	if path.size() == 0 or path[0] != start_node:
		return [] # No hay camino
	
	return path

# Obtiene los datos (info completa) de un nodo/tile por su ID (clave).
func get_node_data(node_id) -> Dictionary:
	if nodes.has(node_id):
		return nodes[node_id]["data"]
	return {}

# Obtiene el tipo de tile de un nodo.
func get_tile_type(node_id) -> int:
	var data = get_node_data(node_id)
	return data["type"] if data.has("type") else null

# Obtiene la información de vecinos (IDs) de un nodo.
func get_neighbors_ids(node_id) -> Array:
	return nodes[node_id]["neighbors"] if nodes.has(node_id) else []

# Obtiene datos completos de los vecinos de un nodo.
func get_neighbors_data(node_id) -> Array:
	var result = []
	for neighbor_id in get_neighbors_ids(node_id):
		result.append(get_node_data(neighbor_id))
	return result

# Encuentra el camino más corto (IDS) entre dos nodos.
func find_shortest_path(start_id, target_id) -> Array:
	return get_shortest_path(start_id, target_id)

# Obtiene vecinos de cierto tipo (IDs) para un nodo dado.
func get_neighbors_by_type(node_id, tile_type) -> Array:
	var result_ids = []
	for neighbor_id in get_neighbors_ids(node_id):
		var data = get_node_data(neighbor_id)
		if data.has("type") and data["type"] == tile_type:
			result_ids.append(neighbor_id)
	return result_ids

# Realiza BFS filtrando por tipo de tile. Retorna array de node_ids.
func bfs_by_type(start_id, tile_type) -> Array:
	# BFS en todo el grafo, recolectando solo los nodos del tipo dado
	var visited = {}
	var queue = [start_id]
	var result = []
	while queue.size() > 0:
		var current = queue.pop_front()
		if visited.has(current):
			continue
		visited[current] = true
		var current_type = get_tile_type(current)
		# Si el nodo actual coincide en tipo, lo agregamos
		if current_type == tile_type:
			result.append(current)
		# Encolar todos los vecinos sin filtrar por tipo
		for neighbor_id in get_neighbors_ids(current):
			if not visited.has(neighbor_id):
				queue.append(neighbor_id)
	return result

## Realiza BFS filtrando por tipo de tile, pero solo en nodos conectados al nodo inicial.
## Esta versión es más eficiente que bfs_by_type ya que no recorre todo el grafo.
##
## @param start_id: ID del nodo desde donde comenzar la búsqueda
## @param tile_type: Tipo de tile a buscar
## @return: Array con los IDs de nodos del tipo especificado conectados al nodo inicial
func bfs_connected_by_type(start_id, tile_type) -> Array:
	if not nodes.has(start_id):
		return []
	
	var visited = {}
	var queue = [start_id]
	var result = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		if visited.has(current):
			continue
		visited[current] = true
		
		var current_type = get_tile_type(current)
		if current_type == tile_type:
			result.append(current)
		
		# Solo agregar vecinos que sean del mismo tipo o que puedan conectar tipos similares
		for neighbor_id in get_neighbors_ids(current):
			if not visited.has(neighbor_id):
				queue.append(neighbor_id)
	
	return result

## Encuentra todos los componentes conectados en el grafo.
##
## @return: Array de Arrays, donde cada sub-array contiene los IDs de nodos de un componente conectado
func find_connected_components() -> Array:
	var visited = {}
	var components = []
	
	for node_id in nodes.keys():
		if not visited.has(node_id):
			var component = []
			_dfs_component(node_id, visited, component)
			components.append(component)
	
	return components

## Función auxiliar para encontrar componentes conectados usando DFS.
func _dfs_component(current_id, visited: Dictionary, component: Array) -> void:
	if visited.has(current_id):
		return
	
	visited[current_id] = true
	component.append(current_id)
	
	for neighbor_id in get_neighbors_ids(current_id):
		_dfs_component(neighbor_id, visited, component)

## Limpia completamente el grafo, eliminando todos los nodos y aristas.
func clear() -> void:
	nodes.clear()

## Obtiene todos los nodos dentro de un rango de distancia específico desde un nodo inicial.
## Útil para sistemas de movimiento, construcción, ataques, etc. en juegos por turnos.
##
## @param start_node_id: ID del nodo desde donde comenzar
## @param max_distance: Distancia máxima a considerar
## @return: Array de Dictionary con datos de los nodos dentro del rango
func get_nodes_within_distance(start_node_id, max_distance: int) -> Array:
	if not nodes.has(start_node_id) or max_distance < 0:
		return []
	
	var result = []
	var visited = {}
	var queue = []
	
	# Inicializar con el nodo de inicio
	queue.append({"node_id": start_node_id, "distance": 0})
	visited[start_node_id] = 0
	
	while queue.size() > 0:
		var current_item = queue.pop_front()
		var current_id = current_item["node_id"]
		var current_distance = current_item["distance"]
		
		# Agregar el nodo actual a los resultados (incluyendo datos completos)
		var node_data = get_node_data(current_id)
		node_data["node_id"] = current_id
		node_data["distance"] = current_distance
		result.append(node_data)
		
		# Si hemos alcanzado la distancia máxima, no explorar más desde este nodo
		if current_distance >= max_distance:
			continue
		
		# Explorar vecinos
		for neighbor_id in get_neighbors_ids(current_id):
			var new_distance = current_distance + 1
			
			# Si no hemos visitado este vecino o encontramos un camino más corto
			if not visited.has(neighbor_id) or visited[neighbor_id] > new_distance:
				visited[neighbor_id] = new_distance
				queue.append({"node_id": neighbor_id, "distance": new_distance})
	
	return result

## Obtiene nodos dentro de un rango filtrando por un tipo específico.
##
## @param start_node_id: ID del nodo desde donde comenzar
## @param max_distance: Distancia máxima a considerar
## @param tile_type: Tipo de tile a filtrar
## @return: Array de Dictionary con datos de los nodos del tipo especificado dentro del rango
func get_nodes_within_distance_by_type(start_node_id, max_distance: int, tile_type) -> Array:
	var all_nodes = get_nodes_within_distance(start_node_id, max_distance)
	var filtered_nodes = []
	
	for node_data in all_nodes:
		if node_data.has("type") and node_data["type"] == tile_type:
			filtered_nodes.append(node_data)
	
	return filtered_nodes

## Obtiene solo los IDs de nodos dentro de un rango (versión optimizada).
##
## @param start_node_id: ID del nodo desde donde comenzar
## @param max_distance: Distancia máxima a considerar
## @return: Array de String con los IDs de nodos dentro del rango
func get_node_ids_within_distance(start_node_id, max_distance: int) -> Array:
	if not nodes.has(start_node_id) or max_distance < 0:
		return []
	
	var result = []
	var visited = {}
	var queue = []
	
	queue.append({"node_id": start_node_id, "distance": 0})
	visited[start_node_id] = 0
	
	while queue.size() > 0:
		var current_item = queue.pop_front()
		var current_id = current_item["node_id"]
		var current_distance = current_item["distance"]
		
		result.append(current_id)
		
		if current_distance >= max_distance:
			continue
		
		for neighbor_id in get_neighbors_ids(current_id):
			var new_distance = current_distance + 1
			
			if not visited.has(neighbor_id) or visited[neighbor_id] > new_distance:
				visited[neighbor_id] = new_distance
				queue.append({"node_id": neighbor_id, "distance": new_distance})
	
	return result
