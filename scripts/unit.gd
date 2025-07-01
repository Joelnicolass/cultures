extends StaticBody3D
class_name Unit

## Clase base para unidades básicas
##
## Funcionalidades actuales:
## - Propiedades básicas (salud, movimiento, ataque, defensa)
## - Integración con EntityManager
## - Estados básicos de unidad

## Propiedades básicas
@export var unit_type: Constants.UnitType = Constants.UnitType.INFANTRY
@export var player_id: int = 1

## Propiedades simplificadas (juego estilo clash of cultures)
@export var attack_range: int = 1
@export var movement_points: int = 2
@export var unit_color: Color = Color.BLUE

## Estado interno
var current_movement: int
var entity_id: String = ""
var current_tile_id: String = ""

## Estados básicos
enum UnitState {
	IDLE,
	MOVING,
	DEAD
}

var current_state: UnitState = UnitState.IDLE

## Referencias visuales
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D

func _ready():
	# Inicializar propiedades
	current_movement = movement_points
	
	# Configurar componentes visuales
	_setup_visual_components()

func _setup_visual_components():
	# Buscar o crear MeshInstance3D
	mesh_instance = get_node("MeshInstance3D") if has_node("MeshInstance3D") else null
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		add_child(mesh_instance)
		
		# Crear mesh básico
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(0.5, 0.8, 0.5)
		mesh_instance.mesh = box_mesh
		
		# Crear material con color del jugador
		var material = StandardMaterial3D.new()
		material.albedo_color = unit_color
		mesh_instance.material_override = material
	
	# Buscar o crear CollisionShape3D
	collision_shape = get_node("CollisionShape3D") if has_node("CollisionShape3D") else null
	if not collision_shape:
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		add_child(collision_shape)
		
		# Crear shape básico
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(0.5, 0.8, 0.5)
		collision_shape.shape = box_shape

## ===== API PARA ENTITY MANAGER =====

## Obtiene el tipo de unidad
func get_unit_type() -> Constants.UnitType:
	return unit_type

## Establece el ID de entidad
func set_entity_id(id: String) -> void:
	entity_id = id

## Obtiene el ID de entidad
func get_entity_id() -> String:
	return entity_id

## Establece el tile actual
func set_current_tile(tile_id: String) -> void:
	current_tile_id = tile_id

## Obtiene el tile actual
func get_current_tile() -> String:
	return current_tile_id

## ===== PROPIEDADES BÁSICAS =====

## Obtiene puntos de movimiento actuales
func get_movement() -> int:
	return current_movement

## Obtiene ID del jugador
func get_player_id() -> int:
	return player_id

## Obtiene el rango de ataque
func get_attack_range() -> int:
	return attack_range

## ===== ACCIONES BÁSICAS =====

## Inflige daño a la unidad
func take_damage(_damage: int) -> void:
	## En clash of cultures, si se recibe un impacto la unidad muere
	current_state = UnitState.DEAD

## Restaura puntos de movimiento
func restore_movement() -> void:
	current_movement = movement_points

## Consume puntos de movimiento
func consume_movement(amount: int) -> bool:
	if current_movement >= amount:
		current_movement -= amount
		return true
	return false

## Verifica si la unidad puede moverse
func can_move() -> bool:
	return current_movement > 0 and current_state != UnitState.DEAD

## Establece el estado de la unidad
func set_state(new_state: UnitState) -> void:
	current_state = new_state
