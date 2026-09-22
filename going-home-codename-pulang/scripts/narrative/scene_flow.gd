class_name SceneFlow
extends CanvasLayer

var veil: ColorRect
var busy: bool = false

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	veil = ColorRect.new()
	veil.color = Color("13241d")
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.modulate.a = 0

func fade_out() -> void:
	busy = true
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(veil, "modulate:a", 1.0, 0.45).finished

func fade_in() -> void:
	await create_tween().tween_property(veil, "modulate:a", 0.0, 0.65).finished
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false
