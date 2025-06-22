extends Node3D

@onready var GRID_NODE = get_node("Grid")

var GRID_SIZE := 200
const HEX_TILE_BASE = preload("res://resources/blend_files/hex_tile_base.blend")
const TILE_SIZE := 2.0

enum HEX_STATUS {
	EMPTY,
	FULL,
}

enum HEX_TYPE {
	BASE,
}

var MAP = {
	"tiles": {},
}

const SCENE_FOR_TILE_TYPE = {
	HEX_TYPE.BASE: HEX_TILE_BASE,
}

# Graph
var graph: Graph

# Hexagonal grid helper
var hex_grid: HexGrid

@export var CHUNK_SIZE := 30

func _ready() -> void:
	graph = Graph.new()
	hex_grid = HexGrid.new()
	_generate_chunk()
	_move_grid_to_center()
	_build_graph()

func _process_tile(_noise_value: float) -> Dictionary:
	var _type
	var _color
	var _status
	var _scale

	if true:
		_status = HEX_STATUS.EMPTY
		_type = HEX_TYPE.BASE
		_color = Color(1.0, 1.0, 0.0)
		_scale = Vector3(1.0, randf_range(10.0, 20.5), 1.0)
	
	return {
		"status": _status,
		"type": _type,
		"color": _color,
		"scale": _scale
	}


func _generate_chunk():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	var noise_texture = noise.get_image(CHUNK_SIZE, CHUNK_SIZE)

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var _noise_value = noise_texture.get_pixel(x, y).r

			var tile_data = _process_tile(_noise_value)
			var _status = tile_data["status"]
			var _type = tile_data["type"]
			var _color = tile_data["color"]
			var _scale = tile_data["scale"]
			var _coord = Vector2(x, y)

			var tile = SCENE_FOR_TILE_TYPE[_type].instantiate()
			GRID_NODE.add_child(tile)
			
			var tile_x := x * TILE_SIZE * cos(deg_to_rad(30))
			var tile_y := y * TILE_SIZE / 2 * 1.5
			var tile_z := 0.0

			if y % 2 == 1:
				tile_x += TILE_SIZE * cos(deg_to_rad(30)) / 2
		
			tile.translate(Vector3(tile_x, tile_z, tile_y))

			var _position = Vector3(tile_x, tile_z, tile_y)

			MAP["tiles"][str(_coord)] = {
				"coord": _coord,
				"position": _position,
				"tile": tile,
				"status": _status,
				"type": _type,
				"color": _color
			}

			if tile.has_method('set_data'):
				tile.set_data({
					"coord": Vector2(x, y),
					"position": _position,
					"tile": tile,
					"status": _status,
					"type": _type,
					"color": _color
				})
			
			if tile.has_method('set_is_hovereable'):
				tile.set_is_hovereable(true)
			

			var tween = get_tree().create_tween()
			var original_scale = tile.scale
			# curve
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(
				tile,
				'scale',
				Vector3(original_scale.x, 1.5, original_scale.z),
				0.1
			)
			tween.set_ease(Tween.EASE_OUT_IN)
			tween.tween_property(
				tile,
				'scale',
				original_scale,
				0.1,
			)
					
			await get_tree().create_timer(0.0001).timeout


func _move_grid_to_center():
	var size_x = CHUNK_SIZE * TILE_SIZE * cos(deg_to_rad(30))
	var size_y = CHUNK_SIZE * TILE_SIZE / 2 * 1.5
	
	GRID_NODE.translate(Vector3(-size_x / 2, 0, -size_y / 2))

	for tile in MAP["tiles"]:
		MAP["tiles"][tile]["position"] -= Vector3(size_x / 2, 0, size_y / 2)
	

func _build_graph() -> void:
	# Construye grafo con nodos y aristas a partir de MAP["tiles"]
	for key in MAP["tiles"].keys():
		var tile_info = MAP["tiles"][key]
		graph.add_node(key, tile_info)
	for key in MAP["tiles"].keys():
		var coord = MAP["tiles"][key]["coord"]
		for neighbor in hex_grid.get_neighbors(coord):
			var neighbor_key = str(neighbor)
			if MAP["tiles"].has(neighbor_key):
				graph.add_edge(key, neighbor_key)