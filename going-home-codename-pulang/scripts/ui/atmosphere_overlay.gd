class_name AtmosphereOverlay
extends Control

var rain: bool = false
var intensity: float = 1.0
var elapsed: float = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if rain:
		elapsed += delta
	if rain:
		queue_redraw()

func _draw() -> void:
	if not rain:
		return
	var count := drop_count()
	for i in range(count):
		var x := fposmod(i * 153.7 - elapsed * 75, size.x)
		var y := fposmod(i * 97.3 + elapsed * lerpf(350, 680, intensity), size.y)
		draw_line(Vector2(x, y), Vector2(x - 4, y + lerpf(9, 24, intensity)), Color(0.78, 0.88, 0.88, lerpf(0.15, 0.30, intensity)), 1)

func drop_count() -> int:
	return int((44 if GameState.settings.quality == 0 else 90) * clampf(intensity, 0, 1))
