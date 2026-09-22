class_name AtmosphereOverlay
extends Control

var rain: bool = false
var elapsed: float = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	elapsed += delta
	if rain:
		queue_redraw()

func _draw() -> void:
	if not rain:
		return
	var count := 44 if GameState.settings.quality == 0 else 90
	for i in range(count):
		var x := fposmod(i * 153.7 - elapsed * 75, size.x)
		var y := fposmod(i * 97.3 + elapsed * 570, size.y)
		draw_line(Vector2(x, y), Vector2(x - 4, y + 19), Color(0.78, 0.88, 0.88, 0.27), 1)
