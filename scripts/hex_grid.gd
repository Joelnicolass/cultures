extends Node
class_name HexGrid

# Definición de deltas para vecinos según fila par o impar en grid hexagonal
const DELTAS_EVEN = [
	Vector2(-1, -1), # NW
	Vector2(0, -1), # NE
	Vector2(1, 0), # E
	Vector2(0, 1), # SE
	Vector2(-1, 1), # SW
	Vector2(-1, 0) # W
]

const DELTAS_ODD = [
	Vector2(0, -1), # NW
	Vector2(1, -1), # NE
	Vector2(1, 0), # E
	Vector2(1, 1), # SE
	Vector2(0, 1), # SW
	Vector2(-1, 0) # W
]

# Retorna un Array de Vector2 con las coordenadas de vecinos hexagonales de un tile
func get_neighbors(coord: Vector2) -> Array:
	var neighbors = []
	var deltas = DELTAS_EVEN if int(coord.y) % 2 == 0 else DELTAS_ODD
	for delta in deltas:
		neighbors.append(coord + delta)
	return neighbors
