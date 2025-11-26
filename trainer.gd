extends CharacterBody2D

@export var pokemon_array: Array[TrainerPokemon] = []

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		pass
