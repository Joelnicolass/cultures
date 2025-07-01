# Sistema de Mapas Hexagonales - Cultures

Sistema básico de mapas hexagonales con unidades para juegos estilo **Clash of Cultures** (4X simplificado) desarrollado en Godot 4.

## 🎯 Filosofía de Desarrollo

### Principios Fundamentales

1. **🚫 NO ADELANTARSE**: Implementar solo lo que se necesita ahora
2. **📈 ESCALABILIDAD**: Código preparado para crecer de forma ordenada
3. **🧹 CÓDIGO LIMPIO**: Funciones simples, responsabilidades claras
4. **🔄 ITERACIÓN**: Desarrollo incremental paso a paso

### Reglas de Oro

- ❌ **Evitar**: Funciones "para futuro uso" que no se utilizan
- ❌ **Evitar**: Complejidad prematura y over-engineering
- ❌ **Evitar**: Implementar múltiples features simultáneamente
- ✅ **Hacer**: Una funcionalidad a la vez, bien hecha
- ✅ **Hacer**: Refactorizar cuando sea necesario, no antes
- ✅ **Hacer**: Documentar decisiones arquitectónicas

## 🎮 Mecánicas Estilo Clash of Cultures

### Simplificaciones Implementadas

- **💥 Combate Simplificado**: 1 impacto = muerte (sin puntos de vida)
- **🎯 Rango de Ataque**: Cada unidad tiene un rango específico para atacar
- **👣 Puntos de Movimiento**: Sistema simple de movimiento por turnos
- **⚔️ Tipos de Unidad**: 7 tipos con características específicas

### Diferencias con Civilization

| Aspecto        | Civilization             | Clash of Cultures   |
| -------------- | ------------------------ | ------------------- |
| **Salud**      | Puntos de vida complejos | 1 impacto = muerte  |
| **Combate**    | Cálculos complejos       | Simple y directo    |
| **Movimiento** | Sistema complejo         | Puntos por turno    |
| **Unidades**   | Muchos tipos             | 7 tipos específicos |

## 🏗️ Estado Actual (Versión Clash of Cultures)

### Funcionalidades Implementadas

- ✅ **Mapa hexagonal básico** con diferentes biomas
- ✅ **Sistema de unidades simplificado** (7 tipos disponibles)
- ✅ **Movimiento con puntos** por turno
- ✅ **Rango de ataque** específico por unidad
- ✅ **Combate simplificado** (1 impacto = muerte)
- ✅ **Dos modos de juego**: Exploración y Movimiento
- ✅ **Gestión centralizada** a través de EntityManager

### Arquitectura Simplificada

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Lógica Juego   │    │   Visualización │    │   Datos Mapa    │
│                 │    │                 │    │                 │
│ GameActionMgr   │◄──►│  MapVisualizer  │◄──►│   MapManager    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │                                            │
          ▼                                            ▼
┌─────────────────┐                    ┌─────────────────────────┐
│ EntityManager   │                    │    Support Classes      │
│ (Clash Style)   │                    │ Graph │ HexGrid │ Utils │
└─────────────────┘                    └─────────────────────────┘
```

## ⚔️ Sistema de Unidades

### Tipos Disponibles

| Unidad       | Ataque | Movimiento | Rango | Características          |
| ------------ | ------ | ---------- | ----- | ------------------------ |
| **Infantry** | ⚔️     | 2          | 1     | Unidad básica de combate |
| **Archer**   | 🏹     | 2          | 2     | Ataque a distancia       |
| **Priest**   | ✨     | 2          | 1     | _Para expansión futura_  |
| **Cavalry**  | 🐎     | 3          | 1     | Movimiento rápido        |
| **Elephant** | 🐘     | 2          | 1     | Unidad pesada            |
| **Leader**   | 👑     | 2          | 1     | Unidad especial          |
| **Ship**     | ⛵     | 4          | 1     | Movimiento acuático      |

### Propiedades Simplificadas

```gdscript
## Propiedades básicas
@export var unit_type: Constants.UnitType = Constants.UnitType.INFANTRY
@export var player_id: int = 1

## Propiedades de combate (Clash of Cultures)
@export var attack_range: int = 1        # Rango de ataque en tiles
@export var movement_points: int = 2     # Movimiento por turno
@export var unit_color: Color = Color.BLUE

## Estado simplificado
var is_alive: bool = true  # Solo vivo/muerto (sin HP)
```

## 📋 Clases Principales (Adaptadas)

### 🗺️ MapManager

- Gestión del mapa hexagonal
- Carga de tiles desde escena
- Sistema de grafo para conectividad
- Detección de clicks e interacciones

### 🎮 GameActionManager

- **Modo Exploración**: Inspeccionar tiles y unidades
- **Modo Movimiento**: Seleccionar y mover unidades
- Coordinación entre sistemas
- Manejo de selección de tiles

### 👥 EntityManager (Adaptado a Clash of Cultures)

- **Gestión centralizada** de unidades
- **Combate simplificado**: `kill_unit()` (1 impacto = muerte)
- **Consultas optimizadas**: Solo unidades vivas
- **Rango de ataque**: `can_attack_tile()` basado en distancia
- **Valores por defecto** específicos por tipo de unidad

### 🔷 TileGame

- Tiles individuales con diferentes biomas
- Referencias a unidades del editor
- Integración con EntityManager

### 👤 Unit (Simplificado)

- **Propiedades básicas**: tipo, jugador, color
- **Mecánicas Clash**: rango de ataque, puntos de movimiento
- **Estados simples**: Idle, Moving, Dead
- **Sin sistema de vida**: Muerte en 1 impacto

## 🎮 Controles Actuales

| Tecla   | Acción                      |
| ------- | --------------------------- |
| `1`     | Modo Exploración            |
| `2`     | Modo Movimiento de Unidades |
| `SPACE` | Mostrar estado del juego    |
| `Mouse` | Seleccionar tiles           |

## 🔄 Flujo de Trabajo Actual

### 1. Exploración (Modo por defecto)

- Click en tile → Muestra información básica
- Lista unidades presentes (solo vivas)
- Sin funcionalidades complejas

### 2. Movimiento de Unidades

- Click en tile con unidades → Selecciona unidades del jugador actual
- Muestra rango de movimiento visual
- Click en tile vacío → Mueve unidades seleccionadas

## 🚀 Próximos Pasos (Iteración Ordenada)

### Fase 1: Combate Básico

1. Modo de combate
2. Implementar ataques entre unidades
3. Validaciones de rango de ataque
4. Eliminación visual de unidades muertas

### Fase 2: Mecánicas de Turno

1. Sistema de turnos por jugador
2. Consumo de puntos de movimiento
3. Reinicio de movimiento por turno

### Fase 3: Mejoras de UX

1. Feedback visual para rangos de ataque
2. Animaciones de combate básicas
3. Información de unidades en pantalla

### Fase 4: Expansión Gradual

1. Mecánicas específicas de Priest
2. Terrenos con restricciones (agua para Ships)
3. Habilidades especiales de Leader

## 🧹 Cambios Realizados (Simplificación Clash of Cultures)

### ✅ **REFACTORING RECIENTE: Eliminación de Duplicación**

**Problema Solucionado**: `EntityManager` duplicaba propiedades que ya existían en la clase `Unit`

#### Antes (Problemático)

- `EntityManager` tenía `_get_default_attack_range()` y `_get_default_movement_points()`
- `Unit` tenía `attack_range` y `movement_points`
- **Duplicación**: Dos fuentes de verdad para los mismos datos
- **Inconsistencias**: Cambios en `Unit` no se reflejaban en `EntityManager`
- **Escalabilidad limitada**: Modificadores tecnológicos imposibles

#### Después (Corregido)

- ✅ **Fuente única de verdad**: `Unit` define todas las propiedades
- ✅ **Referencias directas**: `EntityManager` usa `unit.get_attack_range()` y `unit.movement_points`
- ✅ **Encapsulamiento mejorado**: Cada clase tiene responsabilidades claras
- ✅ **Preparado para expansión**: Parámetro `movement_modifier` para tecnologías futuras

#### Métodos Mejorados

```gdscript
# EntityManager ahora usa Unit directamente
func create_unit() -> String:
    var unit_instance = Unit.new()  # Crear instancia real
    # Usar propiedades de Unit directamente
    "attack_range": unit_instance.get_attack_range(),
    "movement_points": unit_instance.movement_points,
    "node": unit_instance  # Referencia directa

func move_entity(entity_id: String, to_tile_id: String, movement_modifier: int = 0):
    # Usar métodos de Unit para validar y consumir movimiento
    if unit.can_move() and unit.consume_movement(1):
        # Lógica de movimiento...
```

### Eliminado (Complejidad Civilization)

- ❌ Sistema de puntos de vida complejos
- ❌ Cálculos de daño complejos
- ❌ Múltiples stats por unidad (attack_power, defense_power, etc.)
- ❌ Sistema de experiencia y mejoras
- ❌ **Métodos duplicados**: `_get_default_attack_range()`, `_get_default_movement_points()`

### Implementado (Estilo Clash of Cultures)

- ✅ **Combate 1 impacto = muerte**
- ✅ **Rango de ataque** específico por unidad
- ✅ **Puntos de movimiento** simples
- ✅ **7 tipos de unidad** con características específicas
- ✅ **Estados simplificados** (vivo/muerto)
- ✅ **Encapsulamiento mejorado**: Unit como fuente única de verdad
- ✅ **Preparado para tecnologías**: Parámetros opcionales para modificadores

### Mantenido (Esencial)

- ✅ Mapa hexagonal funcional
- ✅ Movimiento entre tiles
- ✅ EntityManager simplificado (ahora sin duplicación)
- ✅ Dos modos de juego activos

## 🔮 Preparación para Tecnologías

### Sistema de Modificadores (Ya Implementado)

El refactoring incluye preparación para el **árbol tecnológico**:

```gdscript
# Ejemplo de uso futuro
func apply_technology_bonus(unit_id: String, movement_bonus: int):
    entity_manager.move_entity(unit_id, target_tile, movement_bonus)
```

**Ventajas**:

- ✅ No requiere cambios en `Unit` para tecnologías básicas
- ✅ Modificadores se aplican en tiempo real
- ✅ Compatible con sistema de turnos
- ✅ Escalable para diferentes tipos de bonificaciones

## 📝 Notas de Desarrollo

### Decisión: Refactoring Incremental vs Reescritura

**Elegido**: Refactoring incremental siguiendo los principios del README

- **🎯 Una mejora a la vez**: Solo eliminar duplicación (Paso 1)
- **📈 Escalabilidad**: Preparado para Paso 2 (mejorar referencias) y Paso 3 (modificadores)
- **🧹 Código limpio**: EntityManager más simple y Unit más consistente
- **🔄 Sin breaking changes**: API pública mantiene compatibilidad

### Lecciones Aprendidas del Refactoring

1. **Encapsulamiento**: Cada clase debe ser dueña de sus datos
2. **Fuente única de verdad**: Evitar duplicación de propiedades críticas
3. **Preparación gradual**: Cambios pequeños que facilitan expansión futura
4. **Validación temprana**: Corregir errores de compilación inmediatamente

### Próximos Refactorings Planeados

#### Paso 2: Mejorar Referencias (Futuro cercano)

- Cambiar algunos `Dictionary` por tipos específicos
- Mantener compatibilidad con sistema actual
- Mejorar IntelliSense y detección de errores

#### Paso 3: Sistema de Modificadores (Futuro)

- Implementar bonificaciones tecnológicas
- Expandir parámetros opcionales
- Sistema de efectos temporales

### Recordatorios

- 🎯 **Foco**: Una funcionalidad a la vez ✅ (Duplicación eliminada)
- 🔍 **Validación**: Probar cada cambio antes de continuar ✅ (Sin errores)
- 📚 **Documentación**: Actualizar README con cada iteración importante ✅ (Actualizado)
- 🧪 **Experimentación**: Probar mecánicas simples antes de complejas ✅ (Base sólida)

---

_Sistema adaptado a mecánicas Clash of Cultures_  
_Versión: Clash Style v1.1 (Refactoring EntityManager/Unit)_  
_Godot 4.x_
