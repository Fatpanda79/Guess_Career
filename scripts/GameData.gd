extends Node3D

# --- 3D World Nodes ---
@onready var ai_clickable_area = $Area3D

# --- UI Nodes ---
@onready var timer = $Timer
@onready var timer_label = $CanvasLayer/UI_Control/TimerLabel

# REMINDER: Add a Label named "DialogueLabel" back to your UI_Control!
@onready var dialogue_label = $CanvasLayer/UI_Control/DialogueLabel

# The Question Menu UI 
@onready var scroll_container = $CanvasLayer/UI_Control/ScrollContainer
@onready var question_list = $CanvasLayer/UI_Control/ScrollContainer/VBoxContainer
@onready var template_button = $CanvasLayer/UI_Control/ScrollContainer/VBoxContainer/Button

# The Guessing UI
@onready var guess_textbox = $CanvasLayer/UI_Control/HBoxContainer/GuessText
@onready var guess_button = $CanvasLayer/UI_Control/HBoxContainer/Button

# --- Game Variables ---
var game_data = {}
var current_ai_job = {}
var all_questions = []

func _ready():
	# 1. Setup the Timer
	timer.wait_time = 120 # 2 minutes
	timer.one_shot = true
	
	# 2. Hide the menu and the template button initially
	scroll_container.hide() 
	template_button.hide()
	
	# 3. Connect signals via code
	ai_clickable_area.symbol_clicked.connect(_on_3d_symbol_clicked)
	guess_button.pressed.connect(_on_guess_submitted)
	
	# 4. Load data and start the game
	load_json_data()
	if all_questions.size() > 0:
		start_new_round()
	else:
		dialogue_label.text = "Error: Could not load JSON data. Check file path!"

func _process(_delta):
	# Keep updating the Timer UI every frame
	if not timer.is_stopped():
		var time_left = int(timer.time_left)
		var minutes = time_left / 60
		var seconds = time_left % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]
		
	# Only trigger Game Over if the timer label isn't already 00:00 AND we have a job loaded
	elif timer_label.text != "00:00":
		timer_label.text = "00:00"
		if current_ai_job.has("job_title"):
			dialogue_label.text = "Time's up! Game Over. The job was: " + current_ai_job["job_title"]
		else:
			dialogue_label.text = "Game Over. (Error: No job loaded)"

func load_json_data():
	# Updated to look in your specific json folder
	var file = FileAccess.open("res://json/data.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			game_data = json.data
			all_questions = game_data["questions"]
		else:
			print("Error parsing JSON data!")
	else:
		print("File not found at res://json/data.json")

func start_new_round():
	var professions = game_data["professions"]
	current_ai_job = professions[randi() % professions.size()]
	
	dialogue_label.text = "Hello! I am on the career ladder. You have 2 minutes to guess my job!"
	timer.start()

func _on_3d_symbol_clicked():
	# Toggle the visibility of the scroll container
	scroll_container.visible = !scroll_container.visible 
	
	# If we just opened it, populate the questions
	if scroll_container.visible:
		populate_questions() 

func populate_questions():
	# 1. Delete old buttons (but keep the hidden template!)
	for child in question_list.get_children():
		if child != template_button:
			child.queue_free()
		
	# 2. Duplicate the template button for every question in the JSON
	for q in all_questions:
		var new_btn = template_button.duplicate()
		new_btn.show() # Un-hide the copy
		new_btn.text = q["text"]
		new_btn.pressed.connect(_on_question_selected.bind(q["id"]))
		question_list.add_child(new_btn)

func _on_question_selected(q_id):
	# Hide the menu after clicking a question
	scroll_container.hide()
	
	# Check if the AI's current job has an answer mapped to this question
	if current_ai_job["answers"].has(q_id) and current_ai_job["answers"][q_id] != "":
		dialogue_label.text = current_ai_job["answers"][q_id]
	else:
		dialogue_label.text = "That doesn't really apply to my job."

func _on_guess_submitted():
	if timer.is_stopped() or not current_ai_job.has("job_title"): 
		return 
		
	var player_guess = guess_textbox.text.strip_edges().to_lower()
	var actual_job = current_ai_job["job_title"].to_lower()
	
	if player_guess == actual_job:
		timer.stop()
		dialogue_label.text = "YOU GOT IT! I am a " + current_ai_job["job_title"] + "!"
		guess_textbox.text = ""
	else:
		dialogue_label.text = "Nope! Keep guessing!"
		guess_textbox.text = ""
