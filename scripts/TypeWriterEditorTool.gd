@tool
extends Label

@export var typewriter_preview := false : set = _set_preview
@export var preview_text := "Hello from the editor!"  # for preview/testing
@export var char_delay := 0.03
@export var new_text = ""

var _full_text := ""
var _typing := false

var prev_text = preview_text

func _ready():
	text = preview_text

func _process(delta: float) -> void:
	if not _typing and new_text != "":
		text = new_text

func _set_preview(value):
	typewriter_preview = value
	if typewriter_preview and not _typing:
		_typing = true
		typewriter_preview = false  # uncheck immediately after
		_full_text = preview_text
		text = ""
		# run typewriter in editor
		typing_loop()

func typing_loop():
	# NOTE: No `await` in editor context, so we emulate a delay using yield
	# Warning: this runs only in play or with editor hint + workaround
	for i in _full_text.length():
		text += _full_text[i]
		await get_tree().process_frame  # minimal delay
		await get_tree().process_frame
	_typing = false
