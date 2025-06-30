extends Node

## ===== ENUMS =====

## Tipos de recursos disponibles
enum ResourceType {
	WOOD,
	STONE,
	FOOD,
	GOLD,
	SCIENCE,
}


## Unidades disponibles
enum UnitType {
	INFANTRY,
	CAVALRY,
	ELEPHANT,
	LEADER,
	SHIP,
}

## Tipos de edificios disponibles
enum BuildingType {
	FORTRESS,
	TEMPLE,
	MARKET,
	OBSERVATORY,
	ACADEMY,
	PORT,
	OBELISK,
	SETTLEMENT,
}

## Raíces tecnológicas disponibles
enum TechnologicalRootType {
	AGRICULTURE,
	BUILDING,
	NAVIGATION,
	EDUCATION,
	MILITARY,
	RELIGION,
	ECONOMY,
	CULTURE,
	SCIENCE,
	DEMOCRACY,
	AUTOCRACY,
	TEOCRACY,
}

enum TechnologicalSection {
	SECTION_1,
	SECTION_2,
	SECTION_3,
	SECTION_4,
}

enum HappinessType {
	ANGRY,
	NEUTRAL,
	HAPPY,
}

## IBO significa "INTELIGNET BARBARIAN ORDER" -> Representa la IA en el juego
enum IBOActions {
	ADVANCE,
	RECRUIT,
	ATTACK,
	BUILD,
	INFLUENCE,
}

enum BIOME_TYPE {
	BASE, # terreno base
	FOREST, # terreno de bosuqe
	MOUNTAIN, # terreno de montaña
	WATER, # terreno de agua
	DESERT, # terreno de desierto
	GRASS, # terreno de pastizal
}

## ===== DICCIONARIOS DE NOMBRES =====

const RESOURCE_TYPE_NAMES = {
	ResourceType.WOOD: "Madera",
	ResourceType.STONE: "Piedra",
	ResourceType.FOOD: "Comida",
	ResourceType.GOLD: "Oro",
	ResourceType.SCIENCE: "Ciencia",
}

const UNIT_TYPE_NAMES = {
	UnitType.INFANTRY: "Infantería",
	UnitType.CAVALRY: "Caballo",
	UnitType.ELEPHANT: "Elefante",
	UnitType.LEADER: "Líder",
	UnitType.SHIP: "Barco",
}

const BUILDING_TYPE_NAMES = {
	BuildingType.FORTRESS: "Fortaleza",
	BuildingType.TEMPLE: "Templo",
	BuildingType.MARKET: "Mercado",
	BuildingType.OBSERVATORY: "Observatorio",
	BuildingType.ACADEMY: "Academia",
	BuildingType.PORT: "Puerto",
	BuildingType.OBELISK: "Obelisco",
	BuildingType.SETTLEMENT: "Asentamiento",
}

const TECHNOLOGICAL_ROOT_TYPE_NAMES = {
	TechnologicalRootType.AGRICULTURE: "Agricultura",
	TechnologicalRootType.BUILDING: "Construcción",
	TechnologicalRootType.NAVIGATION: "Náutica",
	TechnologicalRootType.EDUCATION: "Educación",
	TechnologicalRootType.MILITARY: "Belicismo",
	TechnologicalRootType.RELIGION: "Espiritualidad",
	TechnologicalRootType.ECONOMY: "Economía",
	TechnologicalRootType.CULTURE: "Cultura",
	TechnologicalRootType.SCIENCE: "Ciencia",
	TechnologicalRootType.DEMOCRACY: "Democracia",
	TechnologicalRootType.AUTOCRACY: "Autocracia",
	TechnologicalRootType.TEOCRACY: "Teocracia",
}

const HAPPINESS_TYPE_NAMES = {
	HappinessType.ANGRY: "Enojado",
	HappinessType.NEUTRAL: "Neutral",
	HappinessType.HAPPY: "Feliz",
}

const IBO_ACTIONS_NAMES = {
	IBOActions.ADVANCE: "Avanzar",
	IBOActions.RECRUIT: "Reclutar",
	IBOActions.ATTACK: "Atacar",
	IBOActions.BUILD: "Construir",
	IBOActions.INFLUENCE: "Influir",
}

## ===== FUNCIONES HELPER =====

## Obtiene el nombre de un tipo de recurso
static func get_resource_name(resource_type: ResourceType) -> String:
	return RESOURCE_TYPE_NAMES.get(resource_type, "Desconocido")

## Obtiene el nombre de un tipo de unidad
static func get_unit_name(unit_type: UnitType) -> String:
	return UNIT_TYPE_NAMES.get(unit_type, "Desconocido")

## Obtiene el nombre de un tipo de edificio
static func get_building_name(building_type: BuildingType) -> String:
	return BUILDING_TYPE_NAMES.get(building_type, "Desconocido")

## Obtiene el nombre de un tipo de raíz tecnológica
static func get_tech_root_name(tech_type: TechnologicalRootType) -> String:
	return TECHNOLOGICAL_ROOT_TYPE_NAMES.get(tech_type, "Desconocido")

## Obtiene el nombre de un tipo de felicidad
static func get_happiness_name(happiness_type: HappinessType) -> String:
	return HAPPINESS_TYPE_NAMES.get(happiness_type, "Desconocido")

## Obtiene el nombre de una acción IBO
static func get_ibo_action_name(action: IBOActions) -> String:
	return IBO_ACTIONS_NAMES.get(action, "Desconocido")
