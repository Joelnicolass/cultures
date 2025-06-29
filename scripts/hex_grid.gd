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

# Convierte una posición 3D (Vector3) a coordenadas de offset en grid hexagonal (col, row)
func world_to_offset(world_pos: Vector3, tile_size: float = 2.0) -> Vector2:
    var full_width = tile_size * cos(deg_to_rad(30))
    var row_height = tile_size * 0.75
    var row = int(round(world_pos.z / row_height))
    # ajustar x según offset de fila impar
    var adjusted_x = world_pos.x - (full_width / 2 if row % 2 == 1 else 0.0)
    var col = int(round(adjusted_x / full_width))
    return Vector2(col, row)

# Retorna un Array de Vector2 con las coordenadas de vecinos hexagonales de un tile (offset rows par/impar)
func get_neighbors(coord: Vector2) -> Array:
    var neighbors = []
    var deltas = DELTAS_EVEN if int(coord.y) % 2 == 0 else DELTAS_ODD
    for delta in deltas:
        neighbors.append(coord + delta)
    return neighbors
