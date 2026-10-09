extends Area3D

signal symbol_clicked

# Notice the underscores added to camera, position, normal, and shape_idx
func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("BOOM! The Area3D was clicked!")
		symbol_clicked.emit()
