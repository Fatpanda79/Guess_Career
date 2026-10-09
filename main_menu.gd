extends Node3D

@onready var play = $CanvasLayer3/Control/play
@onready var easy = $CanvasLayer3/Control/Button
@onready var mid = $CanvasLayer3/Control/Button2
@onready var hard = $CanvasLayer3/Control/Button3
@onready var help = $CanvasLayer3/Control/help
@onready var tutorial = $CanvasLayer3/Control/tutorial
@onready var helpdesk = $CanvasLayer3/Control/TextureRect
@onready var Difficulty = $CanvasLayer3/Control/Difficulty
@onready var hidelabel= $CanvasLayer3/Control/Label2
@onready var tips= $CanvasLayer3/Control/TextureRect/tips
@onready var crossbtn = $CanvasLayer3/Control/TextureRect/crossbtn
func _ready() -> void:
	# Keep the connections so the buttons actually work
	play.pressed.connect(_on_play_button_pressed)
	easy.pressed.connect(_on_easy_button_pressed)
	mid.pressed.connect(_on_mid_button_pressed)
	hard.pressed.connect(_on_hard_button_pressed)
	help.pressed.connect(_on_help_button_pressed)
	crossbtn.pressed.connect(_on_cross_button_pressed)
	tutorial.pressed.connect(_on_tutpressed)
	helpdesk.hide()
	hidelabel.hide()
	tips.hide()
	crossbtn.hide()
	# Run this immediately so the initial states match your UI
	_update_button_visuals()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	
func _on_easy_button_pressed():
	global.easy_state = true 
	global.mid_state = false
	global.hard_state = false
	_update_button_visuals()

func _on_mid_button_pressed():
	global.easy_state = false 
	global.mid_state = true
	global.hard_state = false
	_update_button_visuals()

func _on_hard_button_pressed():
	global.easy_state = false 
	global.mid_state = false
	global.hard_state = true
	_update_button_visuals()

func _update_button_visuals():
	# 1. Purple Style for the active/selected button
	var active_style = StyleBoxFlat.new()
	active_style.bg_color = Color("#7300ff")
	
	# 2. Transparent Style for the unselected buttons
	var transparent_style = StyleBoxEmpty.new()
	
	# Update Easy Button
	if global.easy_state:
		easy.add_theme_stylebox_override("normal", active_style)
		easy.add_theme_color_override("font_color", Color.WHITE)
	else:
		easy.add_theme_stylebox_override("normal", transparent_style)
		easy.add_theme_color_override("font_color", Color.BLACK) # Or whatever color you want your unselected text
		
	# Update Mid Button
	if global.mid_state:
		mid.add_theme_stylebox_override("normal", active_style)
		mid.add_theme_color_override("font_color", Color.WHITE)
	else:
		mid.add_theme_stylebox_override("normal", transparent_style)
		mid.add_theme_color_override("font_color", Color.BLACK)
		
	# Update Hard Button
	if global.hard_state:
		hard.add_theme_stylebox_override("normal", active_style)
		hard.add_theme_color_override("font_color", Color.WHITE)
	else:
		hard.add_theme_stylebox_override("normal", transparent_style)
		hard.add_theme_color_override("font_color", Color.BLACK)

func _on_help_button_pressed():
	helpdesk.show()
	help.hide()
	tutorial.hide()
	easy.hide()
	mid.hide()
	hard.hide()
	Difficulty.hide()
	hidelabel.show()
	play.hide()
	tips.show()
	crossbtn.show()
func _on_cross_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
func _on_tutpressed():
	get_tree().change_scene_to_file("res://tutorial.tscn")
