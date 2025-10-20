extends Node

# Global Game State Script — Autoloaded in Project Settings

# Indicates whether the player is spawning for the first time (e.g. after starting a new game)
# Can be used to trigger intro scene / choosing first pokemon
var first_spawn = true

# Flags for different gameplay states
var battling = false		# Used to trigger battle animation logic
var in_battle = false		# Tracks if player is currently in a battle

# Tracks scene transitions between different areas
var prev_world = "world"	# Previous overworld map
var world = "world"			# Current overworld map

# Player's position when transitioning scenes
var pos_x = 536				# X-coordinate to respawn at
var pos_y = 280				# Y-coordinate to respawn at
var spawn_dir = "down"

var pokecenter_x = 104
var pokecenter_y = 103

# Reference to the player node (assigned at runtime)
var player
var out_of_pokemon

# Flags to coordinate transitions (used to delay or conditionally allow switching)
var changing_pokecenter = false
var changing_battle = false

# Indicates which encounter zone the player is in
# Allows dynamic spawning of specific pokemon based on the zone
var encounter_zone: Area2D = null
var chosen_mon: PokemonResource = null
var mon_level: int = 5

# 🧭 Scene Transition Method
# Changes to a specified scene file based on keyword
func change_scene(scene):
	match scene:
		"battle":
			get_tree().change_scene_to_file("res://scenes/places/battle.tscn")
			world = "battle"
		"pokecenter":
			get_tree().change_scene_to_file("res://scenes/places/pokecenter.tscn")
			world = "pokecenter"
		"world":
			get_tree().change_scene_to_file("res://scenes/places/world.tscn")
			world = "world"
		"pokemon_menu":
			get_tree().change_scene_to_file("res://scenes/ui/pokemon_menu.tscn")
