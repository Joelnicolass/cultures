extends Node

enum TechnologicalSection {
  SECTION_1,
  SECTION_2,
  SECTION_3,
  SECTION_4,
}

enum TechnologicalRootType {
  AGRICULTURE,
  BUILDING,
  NAVIGATION,
  EDUCATION,
  MILITARY,
  RELIGION,
  ECONOMY,
  CULTURE,
  CIENCE,
  DEMOCRACY,
  AUTOCRACY,
  TEOCRACY,
}

var TechnologicalRootTypeNames = {
  TechnologicalRootType.AGRICULTURE: "Agricultura",
  TechnologicalRootType.BUILDING: "Construcción",
  TechnologicalRootType.NAVIGATION: "Náutica",
  TechnologicalRootType.EDUCATION: "Educación",
  TechnologicalRootType.MILITARY: "Belicismo",
  TechnologicalRootType.RELIGION: "Espiritualidad",
  TechnologicalRootType.ECONOMY: "Economía",
  TechnologicalRootType.CULTURE: "Cultura",
  TechnologicalRootType.CIENCE: "Ciencia",
  TechnologicalRootType.DEMOCRACY: "Democracia",
  TechnologicalRootType.AUTOCRACY: "Autocracia",
  TechnologicalRootType.TEOCRACY: "Teocracia",
}

var tech_tree_data = {
  [TechnologicalSection.SECTION_1]: {
    "technologies": [
      #AGRICULTURA
      {
        "id": 1,
        "place": 1,
        "root": TechnologicalRootType.AGRICULTURE,
        "name": "Labranza",
        "description":
          "Tus ciudades pueden ‘Recoger’ alimentos de espacios fértiles y madera de espacios de bosques.",
        "effect": "",
      },
      {
        "id": 2,
        "place": 2,
        "root": TechnologicalRootType.AGRICULTURE,
        "name": "Almacenamiento",
        "description": "Dejas de estar limitado a dos alimentos.",
        "effect": "",
      },
      {
        "id": 3,
        "place": 3,
        "root": TechnologicalRootType.AGRICULTURE,
        "name": "Irrigación",
        "description":
          "Tus ciudades pueden ‘Recoger’ alimentos de espacios yermos. Ignoras los eventos de ‘Hambre’.",
        "effect": "",
      },
      {
        "id": 4,
        "place": 4,
        "root": TechnologicalRootType.AGRICULTURE,
        "name": "Ganadería",
        "description":
          "Pagas 1 alimento (0 si tienes ‘Carreteras’) para ‘Recoger’ de espacios de tierra en un radio de 2 espacios de distancia (una vez por turno).",
        "effect": "",
      },
        #CONSTRUCCIÓN
      {
        "id": 5,
        "place": 1,
        "root": TechnologicalRootType.BUILDING,
        "name": "Minería",
        "description":
          "Tus ciudades pueden ‘Recoger’ minerales de los espacios de montaña.",
        "effect": "",
      },
      {
        "id": 6,
        "place": 2,
        "root": TechnologicalRootType.BUILDING,
        "name": "Ingeniería",
        "description":
          "Revelas la Maravilla de arriba del mazo. Puedes constuir una maravilla en ciudades felices.",
        "effect": "",
      },
      {
        "id": 7,
        "place": 3,
        "root": TechnologicalRootType.BUILDING,
        "name": "Sanidad",
        "description":
          "Puedes pagar 1 único colono con una ficha de felicidad. Ignoras los eventos de ‘Peste’ y ‘Epidemia’.",
        "effect": "",
      },
      {
        "id": 8,
        "place": 4,
        "root": TechnologicalRootType.BUILDING,
        "name": "Carreteras",
        "description":
          "Puedes mover unidades y grupos 2 espacios en lugar de 1. Al mover desde o hasta tus ciudades debes pagar 1 alimento y un mineral.",
        "effect": "",
      },
      # NÁUTICA
      {
        "id": 9,
        "place": 1,
        "root": TechnologicalRootType.NAVIGATION,
        "name": "Pesca",
        "description":
          "Tus ciudades pueden ‘Recoger’ alimentos de un espacio de mar adyacente.",
        "effect": "",
      },
      {
        "id": 10,
        "place": 2,
        "root": TechnologicalRootType.NAVIGATION,
        "name": "Navegación",
        "description":
          "Los barcos pueden ‘Mover’ alrededor del tablero al espacio de mar más cercano en la dirección elegida.",
        "effect": "",
      },
      {
        "id": 11,
        "place": 3,
        "root": TechnologicalRootType.NAVIGATION,
        "name": "Barcos de Guerra",
        "description":
          "Batallas navales + batallas en tierra donde tus ejércitos salgan de barcos: cancelas 1 ‘impacto’ en la primera ronda.",
        "effect": "",
      },

      {
        "id": 12,
        "place": 4,
        "root": TechnologicalRootType.NAVIGATION,
        "name": "Cartografía",
        "description":
          "Al usar la acción de mover, ganas 1 de ideas. Ganas 1 de cultura si usas navegación.",
        "effect": "",
      },
    ],
  },

  [TechnologicalSection.SECTION_2]: {
    "technologies": [
      # EDUCACIÓN
      {
        "id": 13,
        "place": 1,
        "root": TechnologicalRootType.EDUCATION,
        "name": "Escritura",
        "description": "Roba 1 carta de acción y 1 de objetivo.",
        "effect": "",
      },
      {
        "id": 14,
        "place": 2,
        "root": TechnologicalRootType.EDUCATION,
        "name": "Educación Pública",
        "description":
          "Consigues 1 recurso de idea cuando ‘Recoges’ desde una ciudad con una Academia.",
        "effect": "",
      },
      {
        "id": 15,
        "place": 3,
        "root": TechnologicalRootType.EDUCATION,
        "name": "Educación Gratuita",
        "description":
          "Consigues 1 ficha de ánimo cuando compras 1 avance usando oro, ideas o una mezcla de ambos (una vez por turno).",
        "effect": "",
      },
      {
        "id": 16,
        "place": 4,
        "root": TechnologicalRootType.EDUCATION,
        "name": "Filosofía",
        "description":
          "Consigues 1 idea cuando consigues un avance de ‘Ciencia’ y después de conseguir este avance.",
        "effect": "",
      },
      # BELICISMO
      {
        "id": 17,
        "place": 1,
        "root": TechnologicalRootType.MILITARY,
        "name": "Tácticas",
        "description":
          "Puedes ‘Mover’ ejércitos. Puedes usar los efectos de combate en las cartas de acción.",
        "effect": "",
      },
      {
        "id": 18,
        "place": 2,
        "root": TechnologicalRootType.MILITARY,
        "name": "Técnica de Asedio",
        "description":
          "Cancelas la capacidad de una fortaleza: para atacar (pagas 2 maderas) o para cancelar un ‘impacto’ (pagas 2 minerales).",
        "effect": "",
      },
      {
        "id": 19,
        "place": 3,
        "root": TechnologicalRootType.MILITARY,
        "name": "Armas de Acero",
        "description":
          "Tus ejércitos hacen +1 ‘impacto’ en la primera ronda contra ejércitos sin ‘Armas de Acero’ (pagas +2 minerales para adquirirlo).",
        "effect": "",
      },
      {
        "id": 20,
        "place": 4,
        "root": TechnologicalRootType.MILITARY,
        "name": "Levas",
        "description":
          "En cada acción de ‘Construir’ unidades: una sola unidad de ejército se paga con 1 ficha de ánimo.",
        "effect": "",
      },
      # ESPIRITUALIDAD
      {
        "id": 21,
        "place": 1,
        "root": TechnologicalRootType.RELIGION,
        "name": "Mitos",
        "description":
          "Puedes pagar 1 ficha de ánimo para evitar reducir el ánimo de una ciudad debido a una carta de evento.",
        "effect": "",
      },
      {
        "id": 22,
        "place": 2,
        "root": TechnologicalRootType.RELIGION,
        "name": "Rituales",
        "description":
          "Los recursos (excluyendo ideas) pueden gastarse como fichas de ánimo para ‘Mejora Cívica’ en una relación 1:1.",
        "effect": "",
      },
      {
        "id": 23,
        "place": 3,
        "root": TechnologicalRootType.RELIGION,
        "name": "Sacerdocio",
        "description":
          "Los avances de ‘Ciencia’ pueden comprarse sin coste de alimentos (una vez por turno).",
        "effect": "",
      },
      {
        "id": 24,
        "place": 4,
        "root": TechnologicalRootType.RELIGION,
        "name": "Religión Oficial",
        "description":
          "Acción de ‘Aumentar el tamaño de ciudad’: construyes un templo sin pagar alimentos (una vez por turno).",
        "effect": "",
      },
    ],
  },

  [TechnologicalSection.SECTION_3]: {
    "technologies": [
     # ECONOMÍA
      {
        "id": 25,
        "place": 1,
        "root": TechnologicalRootType.ECONOMY,
        "name": "Trueque",
        "description":
          "Acción Gratuita: Descarta una carta a cambio de 1 recurso de oro o de cultura.",
        "effect": "",
      },
      {
        "id": 26,
        "place": 2,
        "root": TechnologicalRootType.ECONOMY,
        "name": "Impuestos",
        "description":
          "CUA: pagas 1 ficha de ánimo y consigues 1 oro por cada ciudad que tengas (una vez por turno).",
        "effect": "",
      },
      {
        "id": 27,
        "place": 3,
        "root": TechnologicalRootType.ECONOMY,
        "name": "Rutas Comerciales",
        "description":
          "Comienzo de turno: consigues 1 alimento por colono/barco en un radio de 2 espacios de una única ciudad de jugador ‘no enfadada’ extranjera (máx. 4).",
        "effect": "",
      },
      {
        "id": 28,
        "place": 4,
        "root": TechnologicalRootType.ECONOMY,
        "name": "Moneda",
        "description":
          "Las rutas comerciales pueden producir oro en lugar de todo o parte de los alimentos.",
        "effect": "",
      },
      # CULTURA
      {
        "id": 29,
        "place": 1,
        "root": TechnologicalRootType.CULTURE,
        "name": "Arte",
        "description":
          "Pagas 1 ficha de cultura para hacer 1 acción de ‘Influencia Cultural’ sin coste de acción (una vez por turno).",
        "effect": "",
      },
      {
        "id": 30,
        "place": 2,
        "root": TechnologicalRootType.CULTURE,
        "name": "Circo y Deportes",
        "description":
          "‘Mejora Cívica’: tus ciudades se consideran 1 tamaño más pequeñas de lo que son realmente (mínimo 1).",
        "effect": "",
      },
      {
        "id": 31,
        "place": 3,
        "root": TechnologicalRootType.CULTURE,
        "name": "Monumentos",
        "description":
          "Revelas la Maravilla de arriba del mazo. Eliges una Maravilla: sólo tú puedes construirla y lo haces sin coste de acción.",
        "effect": "",
      },
      {
        "id": 32,
        "place": 4,
        "root": TechnologicalRootType.CULTURE,
        "name": "Drama y Música",
        "description":
          "Intercambias una ficha de ánimo por una ficha de cultura o viceversa (una vez por turno).",
        "effect": "",
      },
      # CIENCIA
      {
        "id": 33,
        "place": 1,
        "root": TechnologicalRootType.CIENCE,
        "name": "Matemáticas",
        "description":
          "Puedes comprar ‘Ingeniería’ y ‘Carreteras’ sin coste de alimentos.",
        "effect": "",
      },
      {
        "id": 34,
        "place": 2,
        "root": TechnologicalRootType.CIENCE,
        "name": "Astronomía",
        "description":
          "Puedes comprar ‘Cartografía’ y ‘Navegación’ sin coste de alimentos.",
        "effect": "",
      },
      {
        "id": 35,
        "place": 3,
        "root": TechnologicalRootType.CIENCE,
        "name": "Medicina",
        "description": "Tras reclutar, recuperas 1 recurso gastado.",
        "effect": "",
      },
      {
        "id": 36,
        "place": 4,
        "root": TechnologicalRootType.CIENCE,
        "name": "Metalurgia",
        "description":
          "‘Armas de Acero’ no cuesta alimentos ni minerales. Consigues 2 minerales si ya tienes ‘Armas de Acero’.",
        "effect": "",
      },
    ],
  },
  [TechnologicalSection.SECTION_4]: {
    "technologies": [
      # DEMOCRACIA
      {
        "id": 37,
        "place": 1,
        "root": TechnologicalRootType.DEMOCRACY,
        "name": "Votaciones",
        "description":
          "Pagas 1 ficha de ánimo para realizar una acción de ‘Mejora Cívica’ sin coste de acción.",
        "effect": "",
      },
      {
        "id": 38,
        "place": 2,
        "root": TechnologicalRootType.DEMOCRACY,
        "name": "Separación de Poderes",
        "description":
          "Los oponentes no pueden reforzar el alcance/tiradas de ‘Influencia Cultural’ contra tus ciudades ‘felices’.",
        "effect": "",
      },
      {
        "id": 39,
        "place": 3,
        "root": TechnologicalRootType.DEMOCRACY,
        "name": "Libertades Civiles",
        "description":
          "-CUA: consigues 3 fichas de ánimo. -Avance ‘Levas’: 1 unidad de ejército cuesta 2 fichas de ánimo.",
        "effect": "",
      },
      {
        "id": 40,
        "place": 4,
        "root": TechnologicalRootType.DEMOCRACY,
        "name": "Libertad Económica",
        "description":
          "-Tu primera acción de ‘Recoger’ cada turno no tiene coste de acción. -Acciones de ‘Recoger’ adicionales cuestan 2 fichas de ánimo.",
        "effect": "",
      },
      # AUTOCRACIA
      {
        "id": 41,
        "place": 1,
        "root": TechnologicalRootType.AUTOCRACY,
        "name": "Nacionalismo",
        "description":
          "Consigues 1 ficha de ánimo o cultura después de ‘Construir’ al menos un ejército o barco.",
        "effect": "",
      },
      {
        "id": 42,
        "place": 2,
        "root": TechnologicalRootType.AUTOCRACY,
        "name": "Totalitarismo",
        "description":
          "Los oponentes no pueden reforzar el alcance/tiradas de ‘Influencia Cultural’ contra tus ciudades con ejércitos.",
        "effect": "",
      },
      {
        "id": 43,
        "place": 3,
        "root": TechnologicalRootType.AUTOCRACY,
        "name": "Poder Absoluto",
        "description":
          "Pagas 2 fichas de ánimo para realizar una acción extra (una vez por turno).",
        "effect": "",
      },
      {
        "id": 44,
        "place": 4,
        "root": TechnologicalRootType.AUTOCRACY,
        "name": "Trabajo Forzado",
        "description":
          "Pagas 1 ficha de ánimo para hacer que tus ciudades ‘enfadadas’ actúen como ‘neutrales’ este turno cuando sean activadas (las ciudades ‘enfadadas’ siguen pidiéndose activar solo una vez).",
        "effect": "",
      },
      {
        "id": 45,
        "place": 1,
        "root": TechnologicalRootType.TEOCRACY,
        "name": "Dogma",
        "description":
          "Avance de ‘Teocracia’ gratis. Tienes 1 límite de 2 Ideas.",
        "effect": "",
      },
      # TEOCRACIA
      {
        "id": 46,
        "place": 1,
        "root": TechnologicalRootType.TEOCRACY,
        "name": "Culto",
        "description":
          "Pagas 1 ficha de ánimo para realizar una acción de ‘Mejora Cívica’ sin coste de acción.",
        "effect": "",
      },
      {
        "id": 46,
        "place": 2,
        "root": TechnologicalRootType.TEOCRACY,
        "name": "Devoción",
        "description":
          "Los oponentes no pueden reforzar el alcance/tiradas de ‘Influencia Cultural’ contra tus ciudades con Templos.",
        "effect": "",
      },
      {
        "id": 47,
        "place": 3,
        "root": TechnologicalRootType.TEOCRACY,
        "name": "Conversión",
        "description":
          "‘Influencia Cultural’: -Éxito con 1 tirada de 4+ -Éxito = Consigues 1 ficha de Cultura.",
        "effect": "",
      },
      {
        "id": 48,
        "place": 4,
        "root": TechnologicalRootType.TEOCRACY,
        "name": "Fanatismo",
        "description":
          "Batalla en una ciudad con Templo: -VC +2 en la primera tirada de combate. -Batalla perdida = Consigues una unidad de Ejército gratis en una de tus ciudades.",
        "effect": "",
      },
    ],
  },
};