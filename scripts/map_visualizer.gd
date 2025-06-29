extends Node
class_name MapVisualizer

## Clase para manejar la visualización e interacción con mapas hexagonales.
##
## Esta clase se encarga de:
## - Detección de clics en tiles mediante raycast
## - Marcado visual de tiles (escalado, colores, etc.)
## - Manejo de estados de visualización (selección, hover, etc.)
## - Animaciones de feedback visual
##
## Diseñada para ser reutilizable en diferentes contextos de mapas.

signal tile_clicked(tile)
signal tile_hovered(tile)
signal tile_unhovered(tile)

## Configuración de visualización
@export var highlight_scale: Vector3 = Vector3(1.0, 1.2, 1.0)
@export var normal_scale: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var animation_duration: float = 0.15
@export var collision_mask: int = 1

## Estado interno
var camera: Camera3D
var marked_tiles: Array = []
var hovered_tile = null
var selected_tiles: Array = []

## Configuración del visualizador
##
## @param camera_node: Cámara para realizar raycast
func setup(camera_node: Camera3D) -> void:
	camera = camera_node
	
	# En Godot 4, manejamos la entrada directamente con _unhandled_input
	# No necesitamos conectar señales manualmente

## Procesa la entrada del usuario para detectar clics en tiles.
##
## @param event: Evento de entrada
func _unhandled_input(event: InputEvent) -> void:
	if not camera:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_handle_tile_click(event.position)
			get_viewport().set_input_as_handled() # Marcar como procesado
	elif event is InputEventMouseMotion:
		_handle_tile_hover(event.position)

## Maneja los clics en tiles usando raycast.
##
## @param mouse_position: Posición del mouse en pantalla
func _handle_tile_click(mouse_position: Vector2) -> void:
	var clicked_tile = _get_tile_at_position(mouse_position)
	if clicked_tile:
		tile_clicked.emit(clicked_tile)

## Maneja el hover sobre tiles usando raycast.
##
## @param mouse_position: Posición del mouse en pantalla
func _handle_tile_hover(mouse_position: Vector2) -> void:
	var hovered = _get_tile_at_position(mouse_position)
	
	# Si cambió el tile sobre el que está el mouse
	if hovered != hovered_tile:
		# Desmarcar tile anterior
		if hovered_tile:
			tile_unhovered.emit(hovered_tile)
		
		# Marcar nuevo tile
		hovered_tile = hovered
		if hovered_tile:
			tile_hovered.emit(hovered_tile)

## Obtiene el tile en una posición específica de la pantalla usando raycast.
##
## @param screen_position: Posición en pantalla
## @return: Tile encontrado o null
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
	if result and result.collider and result.collider is Tile:
		return result.collider
	
	return null

## Marca un tile visualmente con escala aumentada.
##
## @param tile: Tile a marcar
## @param scale: Escala a aplicar (opcional)
## @param animate: Si debe animarse el cambio
func mark_tile(tile: Node3D, scale: Vector3 = highlight_scale, animate: bool = true) -> void:
	if not tile:
		return
	
	if tile not in marked_tiles:
		marked_tiles.append(tile)
	
	if animate:
		_animate_tile_scale(tile, scale)
	else:
		tile.scale = scale

## Desmarca un tile específico.
##
## @param tile: Tile a desmarcar
## @param animate: Si debe animarse el cambio
func unmark_tile(tile: Node3D, animate: bool = true) -> void:
	if not tile:
		return
	
	marked_tiles.erase(tile)
	
	if animate:
		_animate_tile_scale(tile, normal_scale)
	else:
		tile.scale = normal_scale

## Marca múltiples tiles.
##
## @param tiles: Array de tiles a marcar
## @param scale: Escala a aplicar
## @param animate: Si debe animarse el cambio
## @param cascade_delay: Delay entre animaciones (0 = todas al mismo tiempo)
func mark_tiles(tiles: Array, scale: Vector3 = highlight_scale, animate: bool = true, cascade_delay: float = 0.0) -> void:
	for i in range(tiles.size()):
		var tile = tiles[i]
		if tile is Node3D:
			if tile not in marked_tiles:
				marked_tiles.append(tile)
			
			if animate and cascade_delay > 0:
				# Animación en cascada
				get_tree().create_timer(i * cascade_delay).timeout.connect(
					func(): _animate_tile_scale(tile, scale)
				)
			elif animate:
				_animate_tile_scale(tile, scale)
			else:
				tile.scale = scale

## Desmarca todos los tiles marcados.
##
## @param animate: Si debe animarse el cambio
func clear_marks(animate: bool = true) -> void:
	for tile in marked_tiles:
		if tile and is_instance_valid(tile):
			if animate:
				_animate_tile_scale(tile, normal_scale)
			else:
				tile.scale = normal_scale
	
	marked_tiles.clear()

## Anima la escala de un tile.
##
## @param tile: Tile a animar
## @param target_scale: Escala objetivo
func _animate_tile_scale(tile: Node3D, target_scale: Vector3) -> void:
	if not tile.get_tree():
		return
	
	var tween = tile.get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(tile, "scale", target_scale, animation_duration)

## Alterna el estado de marcado de un tile.
##
## @param tile: Tile a alternar
## @param animate: Si debe animarse el cambio
func toggle_tile_mark(tile: Node3D, animate: bool = true) -> void:
	if tile in marked_tiles:
		unmark_tile(tile, animate)
	else:
		mark_tile(tile, highlight_scale, animate)

## Selecciona un tile (diferente a marcado, para múltiples estados).
##
## @param tile: Tile a seleccionar
## @param clear_previous: Si debe limpiar selecciones anteriores
func select_tile(tile: Node3D, clear_previous: bool = true) -> void:
	if clear_previous:
		clear_selection()
	
	if tile not in selected_tiles:
		selected_tiles.append(tile)
		# Aplicar algún efecto visual de selección
		_apply_selection_effect(tile)

## Deselecciona un tile.
##
## @param tile: Tile a deseleccionar
func deselect_tile(tile: Node3D) -> void:
	selected_tiles.erase(tile)
	_remove_selection_effect(tile)

## Limpia todas las selecciones.
func clear_selection() -> void:
	for tile in selected_tiles:
		if tile and is_instance_valid(tile):
			_remove_selection_effect(tile)
	selected_tiles.clear()

## Aplica efecto visual de selección.
##
## @param tile: Tile a aplicar efecto
func _apply_selection_effect(tile: Node3D) -> void:
	# Ejemplo: cambiar el color del material
	if tile.has_method("set_selection_highlight"):
		tile.set_selection_highlight(true)
	# O cualquier otro efecto visual

## Remueve efecto visual de selección.
##
## @param tile: Tile a remover efecto
func _remove_selection_effect(tile: Node3D) -> void:
	if tile.has_method("set_selection_highlight"):
		tile.set_selection_highlight(false)

## Obtiene todos los tiles marcados actualmente.
##
## @return: Array con tiles marcados
func get_marked_tiles() -> Array:
	return marked_tiles.duplicate()

## Obtiene todos los tiles seleccionados actualmente.
##
## @return: Array con tiles seleccionados
func get_selected_tiles() -> Array:
	return selected_tiles.duplicate()

## Verifica si un tile está marcado.
##
## @param tile: Tile a verificar
## @return: true si está marcado
func is_tile_marked(tile: Node3D) -> bool:
	return tile in marked_tiles

## Verifica si un tile está seleccionado.
##
## @param tile: Tile a verificar
## @return: true si está seleccionado
func is_tile_selected(tile: Node3D) -> bool:
	return tile in selected_tiles

## Limpia todo el estado del visualizador.
func clear_all() -> void:
	clear_marks(false)
	clear_selection()
	hovered_tile = null
