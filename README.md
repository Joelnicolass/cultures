# Sistema de Mapas Hexagonales - Cultures

Sistema básico de mapas hexagonales con unidades para juegos estilo Civilization desarrollado en Godot 4.

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

## 🏗️ Estado Actual (Versión Minimalista)

### Funcionalidades Implementadas

- ✅ **Mapa hexagonal básico** con diferentes biomas
- ✅ **Sistema de unidades básico** (Warrior, Archer, Scout, Settler, Worker)
- ✅ **Movimiento de unidades** entre tiles
- ✅ **Dos modos de juego**: Exploración y Movimiento
- ✅ **Gestión centralizada** a través de EntityManager
- ✅ **Integración tile-unidad** desde editor

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
│ (Solo Unidades) │                    │ Graph │ HexGrid │ Utils │
└─────────────────┘                    └─────────────────────────┘
```

## 📋 Clases Principales (Simplificadas)

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

### 👥 EntityManager

- Gestión centralizada de unidades
- Registro desde editor y runtime
- Consultas por tile y jugador
- Movimiento entre tiles

### 🔷 TileGame

- Tiles individuales con diferentes biomas
- Referencias a unidades del editor
- Integración con EntityManager

### 👤 Unit

- Propiedades básicas (salud, movimiento, ataque, defensa)
- Estados simples (Idle, Moving, Dead)
- Integración con EntityManager

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
- Lista unidades presentes
- Sin funcionalidades complejas

### 2. Movimiento de Unidades

- Click en tile con unidades → Selecciona unidades del jugador actual
- Muestra rango de movimiento visual
- Click en tile vacío → Mueve unidades seleccionadas

## 🚀 Próximos Pasos (Iteración Ordenada)

### Fase 1: Mejorar Movimiento Básico

1. Validaciones de movimiento (terreno, obstáculos)
2. Costo de movimiento por tipo de terreno
3. Animaciones básicas de movimiento

### Fase 2: Mejoras de UX

1. Feedback visual mejorado
2. Información de tile en pantalla
3. Controles más intuitivos

### Fase 3: Mecánicas Básicas

1. Puntos de movimiento por turno
2. Sistema de turnos simple
3. Múltiples jugadores básico

### Fase 4: Expansión Gradual

1. Tipos de unidades específicos
2. Combate básico
3. Construcción simple

## 🧹 Limpieza Realizada

### Eliminado (Over-engineering)

- ❌ Sistema de buildings complejo
- ❌ Modos de juego no utilizados (Combat, Diplomacy, Building)
- ❌ Funciones de construcción prematuras
- ❌ Sistema de recursos complejos
- ❌ Árbol tecnológico (tech_tree.gd)
- ❌ Funcionalidades "para futuro"

### Mantenido (Esencial)

- ✅ Mapa hexagonal funcional
- ✅ Unidades básicas
- ✅ Movimiento simple
- ✅ EntityManager simplificado
- ✅ Dos modos de juego activos

## 📁 Archivos Principales

```
scripts/
├── map_manager.gd         # Gestión del mapa
├── game_action_manager.gd # Lógica de juego básica
├── entity_manager.gd      # Gestión de unidades
├── tile_game.gd          # Tiles individuales
├── unit.gd               # Unidades básicas
├── map_2v_2.gd           # Script principal
├── map_visualizer.gd     # Visualización
├── graph.gd              # Sistema de grafo
├── hex_grid.gd           # Cálculos hexagonales
└── tile_utilities.gd     # Utilidades básicas
```

## 📝 Notas de Desarrollo

### Lecciones Aprendidas

1. **Simplicidad primero**: Es mejor tener poco que funcione bien que mucho a medias
2. **Iteración controlada**: Cada feature debe completarse antes de la siguiente
3. **Refactoring oportuno**: Limpiar código cuando se vuelve complejo, no preventivamente
4. **Documentación actualizada**: Mantener README alineado con la realidad del código

### Recordatorios

- 🎯 **Foco**: Una funcionalidad a la vez
- 🔍 **Validación**: Probar cada cambio antes de continuar
- 📚 **Documentación**: Actualizar README con cada iteración importante
- 🧪 **Experimentación**: Probar en small scale antes de implementar

---

_Sistema simplificado para desarrollo iterativo_  
_Versión: Minimalista v1.0_  
_Godot 4.x_
