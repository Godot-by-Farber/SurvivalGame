

# SurvivalGame

No es un repositorio oficial, aquí solo sigo el curso de Godot de [Eerik Hirvonen](https://www.udemy.com/user/eerik-hirvonen/)

![screenshot](https://raw.github.com/afarber/SurvivalGame/master/screenshot.png)

---

## Tabla de Contenidos
- [Vista General del Proyecto](#project-overview)
- [Vista General de la Arquitectura](#architecture-overview)
- [Sistemas de Clases](#class-systems)
- [Archivos de Recursos](#resource-files)
- [Sistemas de Gameplay](#gameplay-systems)
- [Notas de Desarrollo](#development-notes)

---

## Vista General del Proyecto

Este es un juego de supervivencia en 3D construido en Godot 4.4 siguiendo un curso de Eerik Hirvonen. El juego cuenta con mecánicas de recolección de recursos, fabricación, construcción y supervivencia en un entorno de isla.

### Estadísticas del Proyecto
- **Total de Archivos Personalizados**: 143 (excluyendo complementos)
- **Clases de GDScript**: 46 clases personalizadas
- **Archivos de Escena**: 58 archivos .tscn
- **Archivos de Recursos**: 39 recursos .tres
- **Motor**: Godot 4.4 (Forward Plus)
- **Escena Principal**: `res://game/main_game.tscn`

---

## Vista General de la Arquitectura

### Sistema Central de Eventos (Bus de Señales)
**Archivo**: `game/event_system.gd`

El juego utiliza un sistema de eventos centralizado que actúa como un autoload global. Todos los sistemas principales del juego se comunican a través de 41 señales con prefijos específicos:

- **BUL_*** - Sistema de avisos/UI (5 señales)
- **INV_*** - Sistema de inventario (9 señales)
- **PLA_*** - Acciones y estadísticas del jugador (5 señales)
- **EQU_*** - Sistema de equipamiento (4 señales)
- **SFX_*** - Efectos de sonido (2 señales)
- **MUS_*** - Sistema de música (1 señal)
- **STA_*** - Gestión de etapas/escenas (1 señal)
- **GAM_*** - Estado del juego (4 señales)
- **HUD_*** - Visibilidad de la HUD (2 señales)
- **SET_*** - Configuración (6 señales)
- **SPA_*** - Sistema de aparición (2 señales)

### Patrones Arquitectónicos Clave

1. **Desacoplamiento Basado en Señales** - Todos los sistemas se comunican a través de EventSystem, eliminando dependencias directas entre los sistemas del juego
2. **Diseño Basado en Configuración** - Registros de enums (ItemConfig, BulletinConfig, StageConfig) para la gestión centralizada de activos
3. **Patrón de Gestor** - 12 gestores singleton para diferentes sistemas con una clara separación de responsabilidades
4. **Contenido Basado en Recursos** - Todos los objetos definidos como recursos .tres para un desarrollo impulsado por datos
5. **Composición de Escenas** - Plantillas para patrones comunes (recogibles, equipables, golpeables)
6. **Máquinas de Estado** - Utilizadas para el comportamiento de IA de animales, estados del jugador y estados del equipamiento

---

## Sistemas de Clases

### 1. Sistema de Actores (`actors/`)

#### Sistema de Jugador (`actors/player/`)

| Clase | Archivo | Propósito |
|-------|------|---------|
| **Player** | `player.gd` | Controlador principal del personaje (extiende CharacterBody3D) |
| ItemHolder | `item_holder.gd` | Gestiona los visuales del objeto equipado |
| InteractionRayCast | `interaction_ray_cast.gd` | Maneja la detección de interacción con objetos |
| MainCamera | `main_camera.gd` | Controlador de cámara en primera persona |

**Características del Jugador**:
- Velocidades de movimiento: normal (3.0 u/s), sprint (5.0 u/s)
- Consumo de energía durante el movimiento
- Mecánicas de salto con gravedad
- Controles de cámara con mouse (sensibilidad 0.005)
- Audio de pasos con temporización por intervalo
- Gestión de estados de congelación/descongelación

#### Sistema de Animales (`actors/animals/`)

| Clase | Archivo | Propósito |
|-------|------|---------|
| **Animal** | `animal.gd` | Personaje base de IA para vacas/lobos |
| (Instancias) | `cow.tscn`, `wolf.tscn` | Implementaciones específicas de animales |

**Estados de Animales** (Enum):
- Inactivo, Deambular, Muerto, Huir, Herido, Perseguir, Atacar

**Características de Animales**:
- Búsqueda de rutas con agente de navegación
- Detección de área de visión
- Soporte para múltiples animaciones
- Sistema de salud/daño
- Soltura de carne al morir
- Velocidades y temporizadores configurables

---

### 2. Sistema de Objetos Interactivos (`interactables/`)

#### Clase Base Interactiva
| Clase | Archivo | Propósito |
|-------|------|---------|
| **Interactable** | `interactable.gd` | Area3D base para todos los objetos interactivos |

#### Objetos Recogibles (`interactables/pickuppables/`)
| Clase | Archivo | Propósito |
|-------|------|---------|
| **Pickuppable** | `pickuppable.gd` | Clase base para objetos recogibles |
| (Escenas) | Múltiples plantillas .tscn | Recogibles rígidos y estáticos |

**Variantes Recogibles**:
- **Objetos estáticos**: plant, fruit, mushroom, stone, stick
- **Objetos rígidos**: log, coal, flintstone, raw meat
- Plantillas para objetos personalizados

#### Interactivos Especiales
| Clase | Archivo | Propósito |
|-------|------|---------|
| InteractableCooker | `cooker/interactable_cooker.gd` | Interacción con estación de cocción |
| InteractableRaft | `interactable_raft.gd` | Interacciones específicas de la balsa |
| InteractableSleepPoint | `interactable_sleep_point.gd` | Mecánicas de descanso |

---

### 3. Sistema de Objetos y Equipamiento (`items/equippables/`)

#### Jerarquía de Clases
```
EquippableItem (Base - extiende Node3D)
├── EquippableWeapon (detección de daño, verificación de golpe)
├── EquippableConsumable (cambios en salud/energía)
└── EquippableConstructable (vista previa de colocación, verificación de validez)
```

#### EquippableItem
**Clase Base**: Node3D
- Gestiona animaciones a través de AnimationPlayer
- Gestión de capas visuales (capa 2 para cámara equipable)
- `try_to_use()` - reproduce animación

#### EquippableWeapon
**Extiende**: EquippableItem

**Características**:
- Referencia a recurso de arma
- Verificación de golpe mediante raycasting (capa física 8)
- Generación de efectos de partículas al impactar
- Consumo de energía al usar
- Reproducción de audio de golpe

#### EquippableConsumable
**Extiende**: EquippableItem

**Características**:
- Restauración de salud
- Restauración de energía
- Auto-eliminación después del consumo

#### EquippableConstructable
**Extiende**: EquippableItem

**Características**:
- Malla de vista previa de colocación con cambio de materiales
- Detección de colocación válida/inválida (materiales verde/rojo)
- Detección de colisiones mediante Area3D
- Verificación de validez de construcción mediante raycast
- Generación de escena de construcción

**Escenas Equipables**: Más de 15 variantes equipables que incluyen hacha, pico, tienda, fogata, antorcha, balsa, consumibles

---

### 4. Sistema de Recursos (`resources/`)

#### Configuración de Objetos (`game/configs/item_config.gd`)
Gestión centralizada de objetos basada en enums:

**Enum ItemConfig.Keys**:
```gdscript
# Recogibles
Stick, Stone, Plant, Mushroom, Fruit, Log, Coal, Flintstone, RawMeat, CookedMeat

# Fabricables
Axe, Pickaxe, Campfire, Multitool, Rope, Tinderbox, Torch, Tent, Raft
```

Mapea las claves de objetos a archivos de recursos y rutas de escenas para la gestión centralizada de activos.

#### Clases de Recursos de Objetos (`resources/items/`)

| Clase | Archivo | Base | Propósito |
|-------|------|------|---------|
| **ItemResource** | `item_resource.gd` | Resource | Definición base de objeto |
| **WeaponItemResource** | `weapon_item_resource.gd` | ItemResource | Armas (daño, rango, energía) |
| **ConsumableItemResource** | `consumable_item_resource.gd` | ItemResource | Consumibles (salud, energía) |

**Propiedades de ItemResource**:
- item_key, display_name, icon, description
- is_equippable, cooking_recipe

**Más de 35 archivos de recursos de objetos** que cubren los 19 tipos de objetos

#### Sistema de Fabricación (`resources/crafting_blueprints/`)

| Clase | Archivo | Propósito |
|-------|------|---------|
| **CraftingBlueprintResource** | `crafting_blueprint.gd` | Clase base de planos |
| **CraftingBlueprintCostDataResource** | `crafting_blueprint_cost_data.gd` | Definiciones de costo |
| (Instancias) | 9x archivos .tres de planos | Recetas de fabricación individuales |

**Características de Fabricación**:
- Requisitos de objetos basados en costos
- Requisitos de herramientas (multitool, tinderbox)
- 9 objetos fabricables: Axe, Pickaxe, Campfire, Multitool, Rope, Tinderbox, Torch, Tent, Raft

**Planos de Fabricación** (9 archivos):
- axe_blueprint.tres
- pickaxe_blueprint.tres
- campfire_blueprint.tres
- multitool_blueprint.tres
- rope_blueprint.tres
- tinderbox_blueprint.tres
- torch_blueprint.tres
- tent_blueprint.tres
- raft_blueprint.tres

#### Sistema de Cocción (`resources/cooking_recipes/`)

| Clase | Archivo | Propósito |
|-------|------|---------|
| **CookingRecipeResource** | `cooking_recipe_resource.gd` | Definición de receta de cocción |
| (Instancias) | Archivos .tres | Recetas individuales (meat_recipe.tres) |

**Propiedades de Cocción**:
- uncooked_item, uncooked_item_visuals
- cooked_item, cooked_item_visuals
- cooking_time

#### Objetos Golpeables (`resources/hittable_object_attributes/`)

| Clase | Archivo | Propósito |
|-------|------|---------|
| **HittableObjectAttributes** | `hittable_object_attributes.gd` | Definición de objetivo golpeable |
| (Instancias) | 3x archivos .tres | Atributos de árbol, carbón, sílex |

**Propiedades**:
- drop_item_key, max_health, weapon_filter

---

### 5. Gestores del Juego (`game/managers/`)

**12 gestores singleton** para diferentes sistemas:

| Gestor | Archivo | Responsabilidad |
|---------|------|-----------------|
| **BulletinController** | `bulletin_controller.gd` | Ciclo de vida de paneles UI (crear/destruir) |
| **InventoryManager** | `inventory_manager.gd` | Almacenamiento y manipulación de objetos |
| **EquippedItemManager** | `equipped_item_manager.gd` | Gestión de barra de objetos activos |
| **PlayerStatsManager** | `player_stats_manager.gd` | Seguimiento de salud/energía (máx 100 cada uno) |
| **StageController** | `stage_controller.gd` | Carga/transiciones de escenas |
| **SFXController** | `sfx_controller.gd` | Reproducción de efectos de sonido |
| **MusicController** | `music_controller.gd` | Gestión de estado de música |
| **SettingsController** | `settings_controller.gd` | Persistencia de configuraciones del juego |
| **HUDController** | `hud_controller.gd` | Gestión de visibilidad de la HUD |
| **GameFadeController** | `game_fade_controller.gd` | Animaciones de desvanecimiento de pantalla |
| **DayNightCycleAnimPlayer** | `day_night_cycle_anim_player.gd` | Animación de progresión del tiempo |
| **SleepManager** | `sleep_manager.gd` | Mecánicas de descanso |
| **Spawner** | `spawner.gd` | Sistema de instanciación de escenas |

#### InventoryManager
**Estructura**:
- Inventario: 28 slots fijos
- Barra rápida: 9 slots fijos

**Métodos Clave**:
- `try_to_pickup_item()`
- `switch_two_item_indexes()`
- `add_item()`, `delete_item_by_index()`
- `delete_blueprint_costs()`
- `get_free_slots()`

#### EquippedItemManager
**Características**:
- Rastrea el slot activo de la barra rápida
- Maneja entrada de teclas rápidas (1-9)
- Estado de equipar/desequipar objeto
- Responde a cambios en el inventario

#### PlayerStatsManager
**Constantes**:
- MAX_ENERGY = 100.0
- MAX_HEALTH = 100.0

**Métodos**:
- `change_energy()`, `change_health()`

---

### 6. Clases de Configuración (`game/configs/`)

| Configuración | Archivo | Propósito |
|--------|------|---------|
| **ItemConfig** | `item_config.gd` | Definiciones y mapeos centrales de objetos |
| **BulletinConfig** | `bulletin_config.gd` | Enumeración de paneles UI |
| **StageConfig** | `stage_config.gd` | Enumeración de escenas (Island, MainMenu, Credits) |
| **MusicConfig** | `music_config.gd` | Enumeración de pistas de música |
| **SFXConfig** | `sfx_config.gd` | Enumeración de efectos de sonido |
| **VFXConfig** | `vfx_config.gd` | Enumeración de efectos de partículas |

**Enum BulletinConfig.Keys**:
- InteractionPrompt, CraftingMenu, CookingMenu, PauseMenu, SettingsMenu

**Enum StageConfig.Keys**:
- Island (gameplay principal), MainMenu, Credits

---

### 7. Sistema de Objetos (`objects/`)

#### Objetos Golpeables (`objects/hittable_objects/`)

**HittableObject** - `hittable_object.gd` (extiende Node3D)

**Características**:
- Sistema de salud con filtrado de armas
- `register_hit()` - aplica daño del arma
- `die()` - genera objetos sueltos en puntos de aparición
- Malla de residuo opcional para aftermath de destrucción
- Generación de VFX al impactar

**Instancias**:
- Árbol golpeable (suelta troncos)
- Bloque de carbón (suelta carbón)
- Bloque de sílex (suelta sílex)

#### Objetos Construibles (`objects/constructables/`)
**Instancias**: Tienda, Fogata, Balsa

---

### 8. Sistema UI/Avisos (`bulletins/`)

#### Clases Base

| Clase | Archivo | Base | Propósito |
|-------|------|------|---------|
| **Bulletin** | `bulletin.gd` | Control | Panel UI base |
| **PlayerMenuBase** | `player_menus/player_menu_base.gd` | Bulletin | Infraestructura de menús |

#### Menús UI

| Menú | Archivo | Extiende | Propósito |
|------|------|---------|---------|
| CraftingMenu | `player_menus/crafting_menu/crafting_menu.gd` | PlayerMenuBase | UI de fabricación |
| CookingMenu | `player_menus/cooking_menu/cooking_menu.gd` | PlayerMenuBase | UI de cocción |
| PauseMenu | `pause_menu/pause_menu.gd` | Bulletin | Pausa del juego |
| SettingsMenu | `settings_menu/settings_menu.gd` | Bulletin | Configuraciones del juego |
| InteractionPrompt | `interaction_prompt/interaction_prompt.gd` | Bulletin | Indicadores de interacción |
| FadingBulletin | `fading_bulletin/fading_bulletin.gd` | Bulletin | Mensajes temporales |

#### Componentes UI (`ui/custom_nodes/`)
- UIButton
- InventorySlot, HotbarSlot
- CraftButton
- FinalCookingSlot, ScrapItemSlot, StartingCookingSlot

#### Sistema HUD (`ui/hud/`)
- **HotbarUI** - Visualización de barra de equipamiento
- **PlayerStatsContainer** - Visualización de salud/energía

---

### 9. Sistema de Etapas/Scenas (`stages/`)

#### Clase Base de Etapa
**Archivo**: `stage.gd` | **Base**: Node

**Características**:
- Integración con nodo Proton Scatter
- Selección de música
- Señal de finalización de carga
- Control de visibilidad del mouse

#### Implementaciones de Etapas

| Etapa | Archivos | Propósito |
|-------|-------|---------|
| **Island** | `island/island.tscn`, `island/nav_region.gd` | Gameplay principal |
| **MainMenu** | `main_menu/main_menu.tscn`, `main_menu.gd` | Pantalla de inicio |
| **Credits** | `credits/credits_stage.tscn`, `credits_stage.gd` | Pantalla de créditos |

---

## Archivos de Recursos

### Recursos de Objetos (35 archivos)
**Ubicación**: `resources/items/`

**Categorías**:
- **Recogibles**: stick, stone, plant, mushroom, fruit, log, coal, flintstone
- **Alimento**: raw_meat, cooked_meat
- **Herramientas**: axe, pickaxe, multitool, tinderbox
- **Luz**: torch
- **Construcción**: tent, campfire, raft
- **Consumibles**: mushroom, fruit, cooked_meat, rope

### Planos de Fabricación (9 archivos)
**Ubicación**: `resources/crafting_blueprints/`

Cada objeto fabricable tiene un plano que define el costo de materiales y los requisitos de herramientas:
- axe_blueprint.tres
- pickaxe_blueprint.tres
- campfire_blueprint.tres
- multitool_blueprint.tres
- rope_blueprint.tres
- tinderbox_blueprint.tres
- torch_blueprint.tres
- tent_blueprint.tres
- raft_blueprint.tres

### Otros Recursos
- **Atributos Golpeables** (3 archivos): tree, coal, flintstone
- **Recetas de Cocción** (1 archivo): meat_recipe.tres
- **Materiales** (2 archivos): constructable_valid (verde), constructable_invalid (rojo)
- **Temas**: default_ui_theme.tres
- **Shaders**: water_shader.tres

---

## Sistemas de Gameplay

### Bucle Principal de Gameplay
**Explorar → Recoger/Cosechar → Fabricar → Cocinar → Construir → Pelear → Sobrevivir → Descansar**

### Sistema de Inventario
- **28 slots fijos** para inventario principal
- **9 slots de barra rápida** para acceso rápido
- Gestión UI arrastrar y soltar
- Señales para todas las operaciones de inventario

### Sistema de Energía
- Caminar consume energía (-0.05 por metro recorrido)
- Energía por debajo de 0 daña la salud
- Consumibles restauran energía y salud
- Uso de equipamiento consume energía

### Sistema de Fabricación
- **9 objetos fabricables** en total
- Algunos objetos requieren herramientas específicas (multitool, tinderbox)
- Basado en planos con requisitos de costos
- Acceso a través del menú de fabricación

### Sistema de Cocción
- Cocción basada en fogata
- Transformación de carne cruda → carne cocida
- Proceso de cocción basado en tiempo
- Representación visual del progreso de cocción

### Sistema de Construcción
- Colocar estructuras: tienda, fogata, balsa
- Vista previa de colocación con verificación de validez
- Retroalimentación con materiales verde/rojo para colocación válida/inválida
- Detección de colisiones previene estructuras superpuestas

### Sistema de Combate
- Combate basado en armas (hacha, pico)
- Detección de impactos mediante raycast
- Los animales tienen salud y IA de huida/persecución/ataque
- Efectos visuales (VFX) al impactar
- Consumo de energía por ataque

### Mecánicas de Supervivencia
- **Salud**: Máx 100, dañada por agotamiento de energía o combate
- **Energía**: Máx 100, consumida por movimiento y acciones
- **Consumibles**: Restauran salud/energía (mushroom, fruit, cooked meat)
- **Descanso**: Dormir en tienda para recuperarse

### Recolección de Recursos
1. **Recogibles** - Recoger del suelo (stick, stone, plant, mushroom, fruit)
2. **Golpeables** - Golpear con herramientas para recoger (árboles → troncos, rocas → carbón/sílex)
3. **Caza** - Derrotar animales para obtener carne cruda

### Categorías de Objetos (19 en total)
- **10 objetos recogibles**: Stick, Stone, Plant, Mushroom, Fruit, Log, Coal, Flintstone, RawMeat, CookedMeat
- **9 objetos fabricables**: Axe, Pickaxe, Campfire, Multitool, Rope, Tinderbox, Torch, Tent, Raft

---

## Capas de Física

Definidas en `project.godot`:

1. **ground** - Superficies del terreno
2. **actor** - Jugador y NPCs
3. **interactable** - Objetos interactivos
4. **hitbox** - Áreas de detección de impacto
5. **big_rigid_pickuppable** - Objetos físicos grandes
6. **small_rigid_pickuppable** - Objetos físicos pequeños
7. **static_body** - Obstáculos inmóviles
8. **water** - Cuerpos de agua

---

## Notas de Desarrollo

### Estructura del Proyecto
- Todos los objetos están definidos en el enum `ItemConfig.Keys` y mapeados a recursos
- Los archivos de escena usan extensión `.tscn`, los scripts usan `.gd`
- Archivos de audio en `audio/` con carpetas separadas para música y SFX
- Modelos 3D y texturas en `meshes/` y `textures/`
- El juego utiliza un sistema de ciclo día/noche

### Complementos de Terceros

**Proton Scatter** (`addons/proton_scatter/`)
- Utilizado para colocación procedural de vegetación y objetos ambientales
- Proporciona sistema de dispersión basado en modificadores
- Incluye varios modificadores de creación y transformación

### Comandos de Desarrollo
Dado que este es un proyecto de Godot, el desarrollo se realiza principalmente a través del editor de Godot en lugar de herramientas de línea de comandos.

**Motor**: Godot 4.4 (renderizado Forward Plus)
**Escena Principal**: `res://game/main_game.tscn`
**Configuración del Proyecto**: `project.godot` contiene mapas de entrada y configuraciones de capas

---

## Estadísticas de Archivos por Categoría

| Categoría | GDScript | Escenas | Recursos | Total |
|----------|----------|--------|-----------|-------|
| Jugador/Actores | 5 | 5 | 0 | 10 |
| Interactivos | 4 | 15+ | 0 | 19+ |
| Objetos/Equipables | 5 | 15+ | 35 | 55+ |
| Objetos/Golpeables | 2 | 10+ | 3 | 15+ |
| Gestores | 12 | 1 | 0 | 13 |
| UI/Avisos | 8 | 10+ | 1 | 19+ |
| Configuraciones | 6 | 0 | 0 | 6 |
| Etapas | 4 | 3 | 0 | 7 |
| **TOTAL** | **46** | **58** | **39** | **143** |

---

## Créditos

Este proyecto se creó siguiendo el curso de Godot de [Eerik Hirvonen](https://www.udemy.com/user/eerik-hirvonen/).

**Motor**: Godot 4.4
**Licencia**: Proyecto educativo
