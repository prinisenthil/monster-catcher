extends Resource
class_name PokemonMove # Allows this resource to be created in the editor

@export var name: String						# Move name
@export var type: String						# Element/type (e.g. "Fire", "Water")
@export var category: String = "Physical"		# "Physical", "Special", or "Status"
@export var power: int = 40						# Base power (0 for non-damaging moves)
@export var accuracy: int = 100					# Accuracy percent (100 = always hits unless modified)
@export var max_pp: int = 35					# Maximum number of times this move can be used
@export var priority: int = 0					# Determines turn order for moves like Quick Attack
@export var critical_rate: float = 1.0			# Multiplier for critical hit chance (1.0 = normal)
@export var effect_chance: float = 0.0			# Chance to apply a secondary effect (e.g. burn, paralyze)
@export var effect: String						# Description or effect type (e.g. "Burn", "Lower Defense")

@export var description: String					# In-game description text
