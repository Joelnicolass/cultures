extends Node
class_name MapVisualizer

## Visualizador para mapas hexagonales en juegos estilo Civilization (4X).
##
## Gestiona la visualización e interacción con tiles del mapa, incluyendo:
## - Selección principal de tile
## - Estados visuales para diferentes acciones (movimiento, construcción, etc.)
## - Hover y feedback visual
## - Sistema escalable de estados de tiles
##
## Diseñado específicamente para juegos por turnos 4X.

signal tile_clicked(tile)
signal tile_hovered(tile)
signal tile_unhovered(tile)

## Enums para tipos de estado visual
enum TileState {
	NORMAL, # Estado normal
	SELECTED, # Tile seleccionado principal
	HOVERED, # Tile con hover
	MOVEMENT_RANGE, # Tiles donde se puede mover
	ATTACK_RANGE, # Tiles donde se puede atacar
	BUILD_AVAILABLE, # Tiles donde se puede construir
	RESOURCE_VIEW, # Tiles mostrando recursos
	TRADE_ROUTE, # Tiles de ruta comercial
	BORDER, # Tiles de frontera
	INVALID_ACTION # Tiles donde no se puede realizar acción
}

## Configuración de visualización por estado
var state_configs: Dictionary = {
	TileState.NORMAL: {
		"scale": Vector3(1.0, 1.0, 1.0),
		"color_modulate": Color.WHITE,
	},
	TileState.SELECTED: {
		"scale": Vector3(1.05, 1.15, 1.05),
		"color_modulate": Color(1.2, 1.2, 0.8),
	},
	TileState.HOVERED: {
		"scale": Vector3(1.02, 1.08, 1.02),
		"color_modulate": Color.YELLOW
	},
	TileState.MOVEMENT_RANGE: {
		"scale": Vector3(1.0, 1.05, 1.0),
		"color_modulate": Color.CORAL
	},
	TileState.ATTACK_RANGE: {
		"scale": Vector3(1.0, 1.05, 1.0),
		"color_modulate": Color(1.2, 0.8, 0.8),
	},
	TileState.BUILD_AVAILABLE: {
		"scale": Vector3(1.0, 1.05, 1.0),
		"color_modulate": Color(0.9, 0.9, 1.2),
	},
	TileState.RESOURCE_VIEW: {
		"scale": Vector3(1.0, 1.03, 1.0),
		"color_modulate": Color(1.3, 1.1, 0.7),
	},
	TileState.TRADE_ROUTE: {
		"scale": Vector3(1.0, 1.02, 1.0),
		"color_modulate": Color(1.0, 1.2, 1.3),
	},
	TileState.BORDER: {
		"scale": Vector3(1.0, 1.01, 1.0),
		"color_modulate": Color(1.1, 0.9, 1.1),
	},
	TileState.INVALID_ACTION: {
		"scale": Vector3(0.98, 0.95, 0.98),
		"color_modulate": Color(0.7, 0.7, 0.7),
	}
}

## Configuración general
@export var animation_duration: float = 0.15
@export var collision_mask: int = 1

## Estado interno
var camera: Camera3D
var selected_tile: Node3D = null
var hovered_tile: Node3D = null

## Sistema de estados de tiles
## Estructura: { tile: { state: TileState, data: Dictionary } }
var tile_states: Dictionary = {}

## Arrays de acceso rápido organizados por estado
var tiles_by_state: Dictionary = {}

## Configuración del visualizador
func setup(camera_node: Camera3D) -> void:
	camera = camera_node
	_initialize_state_arrays()

## Inicializa los arrays de estados
func _initialize_state_arrays() -> void:
	for state in TileState.values():
		tiles_by_state[state] = []

## Procesa entrada del usuario
func _unhandled_input(event: InputEvent) -> void:
	if not camera:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_handle_tile_click(event.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		_handle_tile_hover(event.position)

## Maneja clics en tiles
func _handle_tile_click(mouse_position: Vector2) -> void:
	var clicked_tile = _get_tile_at_position(mouse_position)
	if clicked_tile:
		tile_clicked.emit(clicked_tile)
		set_selected_tile(clicked_tile)

## Maneja hover sobre tiles
func _handle_tile_hover(mouse_position: Vector2) -> void:
	var hovered = _get_tile_at_position(mouse_position)
	
	# Si es el mismo tile o es un tile seleccionado, no cambiar hover
	if hovered == hovered_tile or (hovered and hovered == selected_tile):
		return
	
	# Limpiar hover anterior
	if hovered_tile and hovered_tile != selected_tile:
		_remove_tile_state(hovered_tile, TileState.HOVERED)
		tile_unhovered.emit(hovered_tile)
	
	# Aplicar nuevo hover
	hovered_tile = hovered
	if hovered_tile and hovered_tile != selected_tile:
		_set_tile_state(hovered_tile, TileState.HOVERED)
		tile_hovered.emit(hovered_tile)

## Raycast para obtener tile en posición
func _get_tile_at_position(screen_position: Vector2):
	if not camera:
		return null
	
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * 1000
	
	var space = camera.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.collision_mask = collision_mask
	
	var result = space.intersect_ray(params)
	if result and result.collider and result.collider is TileGame:
		return result.collider
	return null

## ===== GESTIÓN DE SELECCIÓN PRINCIPAL =====

## Establece el tile seleccionado principal
func set_selected_tile(tile: Node3D) -> void:
	# Limpiar selección anterior
	if selected_tile:
		_remove_tile_state(selected_tile, TileState.SELECTED)
	
	# Establecer nueva selección
	selected_tile = tile
	if selected_tile:
		_set_tile_state(selected_tile, TileState.SELECTED)

## Obtiene el tile seleccionado
func get_selected_tile() -> Node3D:
	return selected_tile

## Limpia la selección principal
func clear_selection() -> void:
	set_selected_tile(null)

## ===== GESTIÓN DE ESTADOS DE TILES =====

## Establece el estado de un tile
func set_tile_state(tile: Node3D, state: TileState, data: Dictionary = {}) -> void:
	_set_tile_state(tile, state, data)

## Establece estados para múltiples tiles
func set_tiles_state(tiles: Array, state: TileState, data: Dictionary = {}) -> void:
	for tile in tiles:
		if tile is Node3D:
			_set_tile_state(tile, state, data)

## Remueve un estado específico de un tile
func remove_tile_state(tile: Node3D, state: TileState) -> void:
	_remove_tile_state(tile, state)

## Remueve un estado de múltiples tiles
func remove_tiles_state(tiles: Array, state: TileState) -> void:
	for tile in tiles:
		if tile is Node3D:
			_remove_tile_state(tile, state)

## Limpia todos los tiles de un estado específico
func clear_state(state: TileState) -> void:
	var tiles_to_clear = tiles_by_state[state].duplicate()
	for tile in tiles_to_clear:
		_remove_tile_state(tile, state)

## Limpia todos los estados excepto selección y hover
func clear_action_states() -> void:
	for state in TileState.values():
		if state != TileState.SELECTED and state != TileState.HOVERED and state != TileState.NORMAL:
			clear_state(state)

## ===== MÉTODOS DE ACCESO =====

## Obtiene todos los tiles en un estado específico
func get_tiles_by_state(state: TileState) -> Array:
	return tiles_by_state[state].duplicate()

## Obtiene el estado actual de un tile
func get_tile_current_state(tile: Node3D) -> TileState:
	if tile in tile_states:
		return tile_states[tile].get("state", TileState.NORMAL)
	return TileState.NORMAL

## Verifica si un tile tiene un estado específico
func has_tile_state(tile: Node3D, state: TileState) -> bool:
	return tile in tiles_by_state[state]

## Obtiene información completa de estados
func get_tiles_info() -> Dictionary:
	var info = {}
	for state in TileState.values():
		var state_name = TileState.keys()[state]
		info[state_name] = {
			"count": tiles_by_state[state].size(),
			"tiles": tiles_by_state[state].duplicate()
		}
	return info

## ===== MÉTODOS PRIVADOS =====

## Establece estado interno de un tile
func _set_tile_state(tile: Node3D, state: TileState, data: Dictionary = {}) -> void:
	if not tile:
		return
	
	# Remover de estado anterior si existe
	if tile in tile_states:
		var old_state = tile_states[tile]["state"]
		tiles_by_state[old_state].erase(tile)
	
	# Establecer nuevo estado
	tile_states[tile] = {
		"state": state,
		"data": data,
		"timestamp": Time.get_ticks_msec()
	}
	
	# Agregar a array de estado
	if tile not in tiles_by_state[state]:
		tiles_by_state[state].append(tile)
	
	# Aplicar efectos visuales
	_apply_visual_state(tile, state)

## Remueve estado de un tile
func _remove_tile_state(tile: Node3D, state: TileState) -> void:
	if not tile or not has_tile_state(tile, state):
		return
	
	# Remover de estructuras de datos
	tile_states.erase(tile)
	tiles_by_state[state].erase(tile)
	
	# Restaurar a estado normal
	_apply_visual_state(tile, TileState.NORMAL)

## Aplica efectos visuales según el estado
func _apply_visual_state(tile: Node3D, state: TileState) -> void:
	if not tile or not tile.get_tree():
		return
	
	var config = state_configs[state]
	
	# Animar escala
	var tween = tile.get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(tile, "scale", config["scale"], animation_duration)
	
	# Modificar color -> APLICAR SHADERS (futuro)
	var highlight_effect: MeshInstance3D = tile.get_node("Effects/Highlight")
	# crear nuevo material en base al existente para evitar errores de referencia
	var new_material = highlight_effect.get_surface_override_material(0).duplicate()
	new_material.set_shader_parameter("highlight_color", config["color_modulate"])
	highlight_effect.set_surface_override_material(0, new_material)

	if state == TileState.NORMAL:
		highlight_effect.visible = false
	else:
		highlight_effect.visible = true
		

## Limpia todo el estado del visualizador
func clear_all() -> void:
	# Limpiar selección
	clear_selection()
	
	# Limpiar hover
	if hovered_tile:
		_remove_tile_state(hovered_tile, TileState.HOVERED)
		hovered_tile = null
	
	# Limpiar todos los estados
	for state in TileState.values():
		clear_state(state)
	
	# Limpiar estructuras de datos
	tile_states.clear()
	_initialize_state_arrays()
