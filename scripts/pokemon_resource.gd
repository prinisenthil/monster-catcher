extends Resource
class_name PokemonResource  # Allows this resource to be created in the editor

# Core pokemon identity
@export var name: String			# Pokémon name (e.g., "Charmander")
@export var element: String			# Pokémon type/element (e.g., "Fire", "Water")

# Base stats used for stat calculation in battle
@export var base_health: int = 11		# Base HP stat
@export var base_attack: int = 10		# Base physical attack
@export var base_defense: int = 10		# Base physical defense
@export var base_sp_attack: int = 10	# Base special attack
@export var base_sp_defense: int = 10	# Base special defense
@export var base_exp: int = 64

@export var speed: int = 100			# Speed determines turn order
@export var accuracy: int = 100			# Base accuracy for moves

@export var level: int = 5				# Default starting level

# Tracking player encounter state (can be used for pokedex function later)
@export var captured: bool = false		# Whether this Pokémon has been caught
@export var seen: bool = false			# Whether this Pokémon has been encountered

# Move data
@export var moves: Array[PokemonMove] = []  # List of move names (max 4 moves)

# Sprites
@export var front_sprite: Texture2D 	# Sprite shown during battle (enemy/front view)
@export var back_sprite: Texture2D		# Sprite shown when it's your Pokémon (back view)
@export var menu_sprite: Texture2D		# Sprite shown in menu or inventory (small icon)
