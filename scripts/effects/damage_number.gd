extends Node2D
class_name DamageNumber
## Floating damage number that rises and fades out.

var amount: int = 0
var is_critical: bool = false

const FLOAT_SPEED := 60.0
const DURATION := 0.8
const SPREAD := 20.0


func _ready() -> void:
	# Randomize horizontal offset for visual variety
	position.x += randf_range(-SPREAD, SPREAD)

	# Animate: float up and fade out
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - FLOAT_SPEED, DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	# Scale pop effect
	scale = Vector2(0.5, 0.5)
	var scale_tween := create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	var text := str(amount)
	if is_critical:
		text += "!"

	var font := ThemeDB.fallback_font
	var font_size := 20 if not is_critical else 28

	# Outline
	var outline_color := Color(0.1, 0.05, 0.0, 0.8)
	for offset in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		draw_string(font, offset, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, outline_color)

	# Main text
	var text_color := Color(1.0, 0.95, 0.8) if not is_critical else Color(1.0, 0.85, 0.2)
	draw_string(font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)
