class_name RouteMap
extends Control

func _ready() -> void:
	custom_minimum_size = Vector2(600, 180)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var points := PackedVector2Array()
	for i in range(15):
		points.append(Vector2(25 + i * (size.x - 50) / 14, 68 + sin(i * 0.5) * 28 + i * 3))
	draw_polyline(points, Color("526f60"), 3, true)
	for i in range(15):
		draw_circle(points[i], 7 if i < 2 else 4, Color("d8ad71") if i < 2 else Color("829384"))
	var font := ThemeDB.fallback_font
	draw_string(font, points[0] + Vector2(-15, -23), "Jakarta", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("f2e6ce"))
	draw_string(font, points[1] + Vector2(-10, 33), "Karawang", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("eac68c"))
	draw_string(font, points[7] + Vector2(-15, -23), "Solo", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("b4c0ad"))
	draw_string(font, points[14] + Vector2(-95, 33), "Banyuwangi", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("f2e6ce"))
