extends Node

class_name Graph

# Diccionario que contiene los nodos.
# Cada nodo es un diccionario con dos entradas:
#   "data": información asociada al nodo (por ejemplo, datos de un tile)
#   "neighbors": un Array con las claves de los nodos vecinos.
var nodes: Dictionary = {}

# Agrega un nodo al grafo con una clave y datos opcionales.
func add_node(node_id, data = null) -> void:
	if not nodes.has(node_id):
		nodes[node_id] = {
			"data": data,
			"neighbors": []
		}

# Agrega una arista no dirigida entre dos nodos.
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
