extends Resource
class_name TrainerPokemon # Allows this to be used and created in the editor as a custom type

# 🎮 Instance-specific data for a Pokémon in a trainer's party

@export var pokemon_data: PokemonResource		# The base stats, sprite, type, and other species info
@export var nickname: String = ""				# Optional nickname for personalization
@export var level: int = 5						# The Pokémon's current level
@export var status_condition: String = ""		# e.g. "Poisoned", "Paralyzed", "" (none)

# 🧠 Calculates the Pokémon's max HP based on level and base stats
func get_max_health() -> int:
	var IV = 15		# Individual Value: pseudo-random hidden stat between 0–31 (simplified here)
	var EV = 0		# Effort Value: gained through training, also simplified to 0
	return ((2 * pokemon_data.base_health + IV + (EV / 4)) * level / 100) + level + 10
