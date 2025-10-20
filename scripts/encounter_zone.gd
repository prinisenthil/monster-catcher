extends Area2D

@export var pokemon_array: Array[PokemonResource] = []
@export var min_level: int = 5
@export var max_level: int = 7

var player_inside := false


# Tracks when something enters encounter zone
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true
		Global.encounter_zone = self

# Tracks when something exits encounter zone
func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" and Global.world == "world":
		player_inside = false
		if Global.encounter_zone == self:
			Global.encounter_zone = null
