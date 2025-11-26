extends CharacterBody2D

const TILE_SIZE = 16
const ANIMATION_SPEED = 4.0  # tiles per second

var inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

var current_dir = "down"
var moving = false
var move_dir = Vector2.ZERO
var target_position = Vector2.ZERO

var tilemap
var camera
var shake_audio

var can_encounter = true
var can_move = true
var battle_playing = false

var shake_intensity = 5
var shake_duration = 0.5
var shake_timer = 0.0

var move_tween: Tween

@onready var sprite = $AnimatedSprite2D
@onready var ray = $RayCast2D

func _ready():
	tilemap = get_parent().get_node("TileMap")
	camera = $WorldCamera
	shake_audio = $BattleTransitionMusic

	global_position = global_position.snapped(Vector2(TILE_SIZE, TILE_SIZE)) + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	target_position = global_position
	sprite.play("down_idle")
	can_move = true

func _physics_process(delta):
	battle_transition(delta)

	if moving or not can_move or battle_playing:
		return

	handle_input()
	check_grass_tile()

func handle_input():
	for action in inputs.keys():
		if Input.is_action_pressed(action):
			move_dir = inputs[action]
			current_dir = get_dir_name(move_dir)
			move_in_direction()
			break

func move_in_direction():
	var base_pos = (global_position - Vector2(TILE_SIZE / 2, TILE_SIZE / 2)).snapped(Vector2(TILE_SIZE, TILE_SIZE)) + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	global_position = base_pos
	target_position = base_pos + move_dir * TILE_SIZE

	# Raycast ahead
	ray.target_position = move_dir * TILE_SIZE
	ray.force_raycast_update()
	if ray.is_colliding():
		sprite.play(current_dir + "_idle")
		return

	sprite.play(current_dir + "_walk")
	moving = true

	move_tween = create_tween()
	move_tween.tween_property(self, "global_position", target_position, 1.0 / ANIMATION_SPEED)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	await move_tween.finished

	moving = false

	# Continue walking if key is still pressed
	if Input.is_action_pressed(get_input_from_dir(move_dir)):
		move_in_direction()
	else:
		sprite.play(current_dir + "_idle")

func get_input_from_dir(dir: Vector2) -> String:
	for action in inputs:
		if inputs[action] == dir:
			return action
	return ""

func get_dir_name(dir: Vector2) -> String:
	match dir:
		Vector2.RIGHT: return "right"
		Vector2.LEFT: return "left"
		Vector2.UP: return "up"
		Vector2.DOWN: return "down"
		_: return "down"

func check_grass_tile():
	if not can_encounter:
		return

	var player_pos = global_position
	var tile_pos = tilemap.local_to_map(tilemap.to_local(player_pos))
	var tile_data = tilemap.get_cell_tile_data(1, tile_pos)

	if tile_data:
		var type = tile_data.get_custom_data("type")
		if type == "grass" and moving:
			can_encounter = false
			$GrassWalking.start()
			randomize_logic()

func randomize_logic():
	if randi() % 5 == 1:
		# Cancel current move tween if one exists
		if move_tween and move_tween.is_running():
			move_tween.kill()
			var base_pos = (global_position - Vector2(TILE_SIZE / 2, TILE_SIZE / 2)).snapped(Vector2(TILE_SIZE, TILE_SIZE)) + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
			global_position = base_pos
			sprite.play(current_dir + "_idle")
			moving = false

		can_move = false
		battle_playing = true
		start_camera_shake()

func _on_grass_walking_timeout() -> void:
	can_encounter = true

func battle_transition(delta):
	if shake_timer > 0:
		shake_timer -= delta
		camera.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		if not shake_audio.playing:
			shake_audio.play()
	else:
		camera.offset = Vector2.ZERO
		shake_audio.stop()

func start_camera_shake():
	shake_timer = shake_duration
	await get_tree().create_timer(0.5).timeout
	#can_move = true
	Global.spawn_dir = current_dir
	Global.changing_battle = true
	Global.world = "battle"

func auto_walk(direction: Vector2, steps: int) -> void:
	can_move = false  # ❌ prevent manual input
	moving = true
	
	for i in steps:
		move_dir = direction
		current_dir = get_dir_name(direction)
		await move_one_tile()  # Do a full tile step

	moving = false
	can_move = true  # ✅ restore input
	sprite.play(current_dir + "_idle")

func move_one_tile() -> void:
	var base_pos = (global_position - Vector2(TILE_SIZE / 2, TILE_SIZE / 2)).snapped(Vector2(TILE_SIZE, TILE_SIZE)) + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	global_position = base_pos
	target_position = base_pos + move_dir * TILE_SIZE

	# Raycast ahead to check for collisions
	ray.target_position = move_dir * TILE_SIZE
	ray.force_raycast_update()

	if ray.is_colliding():
		var collider = ray.get_collider()

		# If it's an Area2D, allow movement and optionally trigger something
		if collider is Area2D:
			print("Ray hit Area2D: ", collider.name)

		else:
			# If it's not an Area2D (e.g., a solid object), block movement
			return

	sprite.play(current_dir + "_walk")

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 1.0 / ANIMATION_SPEED)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	await tween.finished
