extends Area3D

signal symbol_clicked

@onready var questionsearch = $"../CanvasLayer/UI_Control/HBoxContainer4/TextEdit"
@onready var searchbtn = $"../CanvasLayer/UI_Control/HBoxContainer4/Button"

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	# Using your Input Map action named "interact"
	if event.is_action_pressed("interact"):
		print("BOOM! Clicked using the Input Map!")
		symbol_clicked.emit()
