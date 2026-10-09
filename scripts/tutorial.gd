extends Node3D

# --- 3D World Nodes ---
@onready var ai_clickable_area = $Control/CanvasLayer/UI_Control/Askbutton
@onready var player2 = $Control2/Player2
var askbutton_status: bool = true
@onready var player1_material = $Control2/Player.get_active_material(0)
# --- UI Nodes ---
@onready var timer = $Timer
@onready var timer_label = $Control/CanvasLayer/UI_Control/TimerLabel
@onready var dialogue_label = $Control/CanvasLayer/UI_Control/DiaologueLabel

# The Question Menu UI
@onready var scroll_container = $Control/CanvasLayer/UI_Control/ScrollContainer
@onready var question_list = $Control/CanvasLayer/UI_Control/ScrollContainer/VBoxContainer
@onready var template_button = $Control/CanvasLayer/UI_Control/ScrollContainer/VBoxContainer/Button
@onready var questionsearch = $Control/CanvasLayer/UI_Control/HBoxContainer4/TextEdit
@onready var searchbtn = $Control/CanvasLayer/UI_Control/HBoxContainer4/Button

# The Guessing UI
@onready var guess_textbox = $Control/CanvasLayer/UI_Control/HBoxContainer3/TextEdit
@onready var guess_button = $Control/CanvasLayer/UI_Control/HBoxContainer3/Button

# The Job Menu UI
@onready var jobscroll_container = $Control/CanvasLayer/UI_Control/ScrollContainer2
@onready var job_list = $Control/CanvasLayer/UI_Control/ScrollContainer2/VBoxContainer
@onready var job_button = $Control/CanvasLayer/UI_Control/ScrollContainer2/VBoxContainer/Button

# Core System Controls
@onready var restart = $Control/CanvasLayer/UI_Control/Button
@onready var pause_menu = $CanvasLayer2/Control
@onready var pausebtn = $Control/CanvasLayer/UI_Control/pausebtn
@onready var crossbtn = $CanvasLayer2/Control/crossbtn
@onready var restartbtn = $CanvasLayer2/Control/restart
@onready var resume = $CanvasLayer2/Control/resumebtn
@onready var home = $CanvasLayer2/Control/Home
@onready var help = $CanvasLayer2/Control/help
@onready var hidelabel = $CanvasLayer2/Control/Label2
@onready var tips = $CanvasLayer2/Control/tips
@onready var pauselabel = $CanvasLayer2/Control/Label
@onready var guessleft = $Control/CanvasLayer/UI_Control/guessleft
@onready var nextbtn = $Control/CanvasLayer/UI_Control/Next
@onready var skip = $Control/CanvasLayer/UI_Control/skip

# --- UI Custom Theme Styles ---
@onready var styleboxGuess = $Control/CanvasLayer/UI_Control/guessleft.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
@onready var stylebosLabel = $Control/CanvasLayer/UI_Control/guessleft/Label2.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
@onready var stylebox_BtnGuess = $Control/CanvasLayer/UI_Control/HBoxContainer3/Button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
@onready var ask_button = $Control/CanvasLayer/UI_Control/Askbutton.get_theme_stylebox("normal").duplicate() as StyleBoxFlat

# --- Tutorial Arrows ---
@onready var askarrow = $Control/CanvasLayer/UI_Control/Control/Sprite2D2
@onready var guessbtnarrow = $Control/CanvasLayer/UI_Control/Control/Sprite2D3
@onready var guesslabelarrow = $Control/CanvasLayer/UI_Control/Control/Sprite2D
@onready var jobselectionArrow = $Control/CanvasLayer/UI_Control/Control/Sprite2D4

# --- Game Variables ---
var game_data = {}
var current_ai_job = {}
var all_questions = []
var tutmode: bool = true
var state: int = 0
var guesses_left: int = 15 

func _rand_val() -> float:
	return randf_range(0.3, 0.7)

func get_random_color() -> Color:
	var random_hue = randf()
	return Color.from_hsv(random_hue, 1.0, 1.0)

func _ready():
	# Character Material Color Configurations
	$Control2/Player2.get_active_material(0).albedo_color = get_random_color()
	$Control2/Player/Playercap.get_active_material(0).albedo_color = Color(1, 1, 0)
	var cap2_mat = $Control2/Player2/Playercap2.get_active_material(0).duplicate()
	cap2_mat.albedo_color = get_random_color()
	$Control2/Player2/Playercap2.set_surface_override_material(0, cap2_mat)
	if player1_material:
		var unique_material = player1_material.duplicate()
		unique_material.albedo_color = get_random_color() 
		$Control2/Player.set_surface_override_material(0, unique_material)
	
	# Initial UI Visibility States
	restart.hide()
	pause_menu.hide()
	tips.hide()
	scroll_container.hide() 
	template_button.hide()
	questionsearch.hide()
	searchbtn.hide()
	jobscroll_container.hide()
	job_button.hide()
	pausebtn.disabled = true
	
	# Clean slate setup: Ensure all tutorial assets and arrows are hidden at launch
	$Control/CanvasLayer/UI_Control/highlightSoftware.hide()
	guesslabelarrow.hide()
	guessbtnarrow.hide()
	askarrow.hide()
	jobselectionArrow.hide()
	
	# Connect Button Signal Operations
	restart.pressed.connect(_on_restart_button_pressed)
	pausebtn.pressed.connect(_on_pausebtn_pressed)
	crossbtn.pressed.connect(_on_crossbtn_pressed)
	restartbtn.pressed.connect(_on_restart_button_pressed)
	resume.pressed.connect(_on_crossbtn_pressed)
	home.pressed.connect(_on_home_pressed)
	help.pressed.connect(_on_help_button_pressed)
	nextbtn.pressed.connect(_on_nextbtn_pressed)
	skip.pressed.connect(_on_skip_pressed)
	searchbtn.pressed.connect(_on_search_text_changed)
	
	# Connect Interactive Control Elements
	ai_clickable_area.pressed.connect(_on_3d_symbol_clicked)
	guess_button.pressed.connect(_on_guess_submitted)
	timer.timeout.connect(_on_timer_timeout)
	questionsearch.text_changed.connect(_on_search_text_changed) 
	guess_textbox.text_changed.connect(_on_guess_text_changed)
	

	
	load_json_data()
	if all_questions.size() > 0:
		start_new_round()

func _process(_delta):
	if not timer.is_stopped():
		var time_left = int(timer.time_left)
		var minutes = int(time_left) / 60
		var seconds = int(time_left) % 60
		
		timer_label.text = "%02d:%02d" % [minutes, seconds]
		guessleft.text = "Guesses Left: %d" % guesses_left

	if scroll_container.visible or jobscroll_container.visible:
		ai_clickable_area.hide()
	else:
		ai_clickable_area.show()

func _on_timer_timeout():
	timer_label.text = "00:00"
	game_over_lose("Time's up!")

func load_json_data():
	print("--- ATTEMPTING TO LOAD JSON ---")
	var path = "res://json/data.json" 
	if not FileAccess.file_exists(path):
		print("CRITICAL ERROR: Godot cannot find the file at: ", path)
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("CRITICAL ERROR: File exists, but Godot is blocked from opening it!")
		return
		
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		print("CRITICAL ERROR: The JSON text is broken! Error at line ", json.get_error_line())
		return
		
	game_data = json.data
	if game_data.has("questions") and game_data.has("professions"):
		all_questions = game_data["questions"]
		print("SUCCESS: JSON loaded perfectly! ", all_questions.size(), " questions ready.")
	else:
		print("CRITICAL ERROR: JSON loaded, but it is missing the data we need!")

func start_new_round():
	var professions = game_data["professions"]
	
	if tutmode:
		var found_receptionist = false
		for job in professions:
			if job["job_title"].to_lower() == "receptionist":
				current_ai_job = job
				found_receptionist = true
				break
		if not found_receptionist and professions.size() > 0:
			current_ai_job = professions[0]
	else:
		current_ai_job = professions[randi() % professions.size()]
	
	if global.easy_state or (not global.easy_state and not global.mid_state and not global.hard_state):
		timer.wait_time = 300
		guesses_left = 15           
		dialogue_label.text = "  You have 15 guesses \n   to find the correct job!"
	elif global.mid_state:
		timer.wait_time = 210
		guesses_left = 7            
		dialogue_label.text = "  You have 7 guesses \n  to find the correct job!"
	elif global.hard_state:
		timer.wait_time = 120
		guesses_left = 3            
		dialogue_label.text = "Watch out! You only have 3 guesses!"

	timer.one_shot = true
	timer.start()

	# TUTORIAL INITIAL STATE setup: Force-pause and highlight guesses left
	if tutmode:
		timer.paused = true
		state = 0
		var highlight_guesses = guessleft.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
		if highlight_guesses:
			highlight_guesses.border_width_left = 5
			highlight_guesses.border_width_top = 5
			highlight_guesses.border_width_right = 5
			highlight_guesses.border_width_bottom = 5
			highlight_guesses.border_color = Color("30fff0")
			guessleft.add_theme_stylebox_override("normal", highlight_guesses)

# ---------------------------------------------------------
# QUESTION MENU LOGIC
# ---------------------------------------------------------

func _on_3d_symbol_clicked():
	if timer.is_stopped(): return
	scroll_container.visible = !scroll_container.visible 
	dialogue_label.hide()
	
	if askbutton_status == false:
		ai_clickable_area.z_index = 3
		askbutton_status = false
	elif askbutton_status == true:
		ai_clickable_area.z_index = -1
		askbutton_status = true
		
	questionsearch.visible = scroll_container.visible
	searchbtn.visible = scroll_container.visible
	
	if scroll_container.visible:
		jobscroll_container.hide() 
		guess_textbox.text = ""
		questionsearch.text = "" 
		populate_questions("") 
		
		if tutmode and state == 3:
			askarrow.hide()
	else:
		if tutmode and state == 3:
			askarrow.show()

func populate_questions(search_filter: String = ""):
	for child in question_list.get_children():
		if child != template_button:
			child.queue_free()
		
	var q_index = 0
	for q in all_questions:
		var q_text_lower = q["text"].to_lower()
		var filter_lower = search_filter.to_lower()
		
		if filter_lower == "" or q_text_lower.contains(filter_lower):
			var new_btn = template_button.duplicate()
			new_btn.show() 
			new_btn.text = q["text"]
			new_btn.pressed.connect(_on_question_selected.bind(q["id"]))
			question_list.add_child(new_btn)
			
			if tutmode:
				if q_index == 0:
					var highlight_style = new_btn.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
					if highlight_style:
						highlight_style.border_width_left = 5
						highlight_style.border_width_top = 5
						highlight_style.border_width_right = 5
						highlight_style.border_width_bottom = 5
						highlight_style.border_color = Color("30fff0")
						new_btn.add_theme_stylebox_override("normal", highlight_style)
				else:
					new_btn.disabled = true
			q_index += 1

func _on_search_text_changed():
	var current_search = questionsearch.text.strip_edges()
	populate_questions(current_search)

func _on_question_selected(q_id):
	dialogue_label.show()
	scroll_container.hide()
	questionsearch.hide()
	searchbtn.hide()
	questionsearch.text = "" 
	
	askarrow.hide()
	
	if current_ai_job["answers"].has(q_id) and current_ai_job["answers"][q_id] != "":
		dialogue_label.text = current_ai_job["answers"][q_id]
	else:
		dialogue_label.text = "That doesn't really apply to my job."
		
	if tutmode and state == 3:
		state = 4
		_setup_receptionist_tutorial_ui()

# ---------------------------------------------------------
# JOB MENU LOGIC
# ---------------------------------------------------------

func populate_jobs(search_filter: String = ""):
	for child in job_list.get_children():
		if child != job_button:
			child.queue_free()
			
	var professions = game_data["professions"]
	
	for job in professions:
		var job_title = job["job_title"]
		var title_lower = job_title.to_lower()
		var filter_lower = search_filter.to_lower()
		
		if filter_lower == "" or title_lower.contains(filter_lower):
			var new_btn = job_button.duplicate()
			new_btn.show()
			new_btn.text = job_title
			new_btn.pressed.connect(_on_job_selected.bind(job_title))
			job_list.add_child(new_btn)
			
			if tutmode:
				if state == 2:
					if title_lower == "software engineering" or title_lower == "software engineer":
						var highlight_job = new_btn.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
						if highlight_job:
							highlight_job.border_width_left = 5
							highlight_job.border_width_top = 5
							highlight_job.border_width_right = 5
							highlight_job.border_width_bottom = 5
							highlight_job.border_color = Color("30fff0")
							new_btn.add_theme_stylebox_override("normal", highlight_job)
					else:
						new_btn.disabled = true
						
				elif state == 4:
					if title_lower == "receptionist":
						var highlight_job = new_btn.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
						if highlight_job:
							highlight_job.border_width_left = 5
							highlight_job.border_width_top = 5
							highlight_job.border_width_right = 5
							highlight_job.border_width_bottom = 5
							highlight_job.border_color = Color("30fff0")
							new_btn.add_theme_stylebox_override("normal", highlight_job)
					else:
						new_btn.disabled = true

func _on_guess_text_changed():
	if timer.is_stopped(): return
	var current_search = guess_textbox.text.strip_edges()
	
	if current_search.length() > 0:
		jobscroll_container.show()
		scroll_container.hide()
		questionsearch.hide()
		searchbtn.hide()
		if tutmode:
			jobselectionArrow.visible = jobscroll_container.visible
	else:
		jobscroll_container.hide()
		if tutmode:
			jobselectionArrow.hide()
		
	populate_jobs(current_search)

func _on_job_selected(selected_job: String):
	jobselectionArrow.hide()
	jobscroll_container.hide()
	guess_textbox.text = ""
	dialogue_label.show()
	
	if timer.is_stopped(): return 
		
	var actual_job = current_ai_job["job_title"].to_lower()
	
	if selected_job.to_lower() == actual_job:
		timer.stop() 
		dialogue_label.text = "Congrats you won! \nI am a " + current_ai_job["job_title"] + "!"
		guesslabelarrow.hide()
		$Control/CanvasLayer/UI_Control/guessleft/Label2.hide()
		$Control/CanvasLayer/UI_Control/ColorRect.hide()
		restart.hide()
		tutmode = false 
	else:
		guesses_left -= 1
		
		if tutmode and state == 2:
			dialogue_label.text = "No, I'm not a \n " + selected_job + "!\nNotice your Guesses Left decreased!\n Let's get a clue."
			state = 3
			_setup_ask_button_tutorial_ui()
			return 
			
		if guesses_left <= 0:
			guessleft.text = "Guesses Left: 0"
			game_over_lose("Out of guesses!")
		else:
			dialogue_label.text = "No, I'm not a " + selected_job + "! \n Keep guessing!"

func game_over_lose(reason: String):
	timer.stop()
	if current_ai_job.has("job_title"):
		dialogue_label.text = reason + " Game Over. \nThe job was: " + current_ai_job["job_title"]
	restart.show()

func _on_guess_submitted():
	if timer.is_stopped(): return
	#jobscroll_container.visible = !jobscroll_container.visible
	jobscroll_container.show()
	scroll_container.hide()
	questionsearch.hide()
	searchbtn.hide()
	
	# Manually trigger the job population with the current text
	var current_search = guess_textbox.text.strip_edges()
	populate_jobs(current_search)
	
	# Optional: Hide mobile keyboard after pressing search
	guess_textbox.release_focus()
	
	
func _on_restart_button_pressed():
	get_tree().reload_current_scene()

# ---------------------------------------------------------
# PAUSE MENU MANAGEMENT
# ---------------------------------------------------------

func _on_pausebtn_pressed():
	pauselabel.show()
	help.show()
	restartbtn.hide()
	home.show()
	resume.show()
	crossbtn.show()
	hidelabel.hide()
	tips.hide()
	pause_menu.show()
	$Timer.paused = true

func _on_crossbtn_pressed():
	pause_menu.hide()
	$Timer.paused = false
	pauselabel.show()
	help.show()
	restartbtn.show()
	home.show()
	resume.show()
	hidelabel.hide()
	tips.hide()
	
func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_skip_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _on_help_button_pressed():
	help.hide()
	restart.hide()
	restartbtn.hide()
	home.hide()
	hidelabel.show()
	resume.hide()
	tips.show()
	crossbtn.show()
	pauselabel.hide()
	
# ---------------------------------------------------------
# TUTORIAL FLOW SEQUENCING
# ---------------------------------------------------------

func _on_nextbtn_pressed():
	if state == 0:
		# STEP 1 (NEW STATE): Clear guesses highlight, state that we have 5 minutes, and highlight timer
		state = 1
		guessleft.add_theme_stylebox_override("normal", styleboxGuess) # Restore old stylebox
		
		dialogue_label.text = "  You also have a total \n   of 5 minutes to figure it out!"
		
		var highlight_timer = timer_label.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
		if not highlight_timer:
			highlight_timer = StyleBoxFlat.new()
		highlight_timer.border_width_left = 5
		highlight_timer.border_width_top = 5
		highlight_timer.border_width_right = 5
		highlight_timer.border_width_bottom = 5
		highlight_timer.border_color = Color("30fff0")
		timer_label.add_theme_stylebox_override("normal", highlight_timer)
		guessleft.remove_theme_stylebox_override("normal") 
		$Control/CanvasLayer/UI_Control/guessleft/Label2.position = Vector2(500,10)
		$Control/CanvasLayer/UI_Control/guessleft/Label2.text = "\n\n  This is the timer \n  and you have 5 min \n\n"
		dialogue_label.z_index =10
		
		timer_label.z_index = 10
		
	elif state == 1:
		dialogue_label.z_index =0
		# STEP 2: Clear timer highlight, unpause game timer, and trigger guess button guide
		state = 2
		timer.paused = false # Unpause the timer here!
		timer_label.remove_theme_stylebox_override("normal") # Clean up border
		
		$Control/CanvasLayer/UI_Control/guessleft.z_index = -1
		guess_button.z_index = 6
		$Control/CanvasLayer/UI_Control/guessleft/Label2.z_index = 1
		$Control/CanvasLayer/UI_Control/guessleft/Label2.text = "\n\n  PRESS THE GUESS BUTTON \n  and choose Software Engineer  \n\n"
		guessbtnarrow.show()
		
		styleboxGuess.border_width_bottom = 0
		styleboxGuess.border_width_top = 0
		styleboxGuess.border_width_right = 0
		styleboxGuess.border_width_left = 0
		
		stylebox_BtnGuess.border_width_bottom = 5
		stylebox_BtnGuess.border_width_top = 5
		stylebox_BtnGuess.border_width_left = 5
		stylebox_BtnGuess.border_width_right = 5
		stylebox_BtnGuess.border_color = Color("30fff0")
		$Control/CanvasLayer/UI_Control/guessleft/Label2.position = Vector2(300,350)
		$Control/CanvasLayer/UI_Control/guessleft.add_theme_stylebox_override("normal", styleboxGuess)
		$Control/CanvasLayer/UI_Control/HBoxContainer3/Button.add_theme_stylebox_override("normal", stylebox_BtnGuess)
		
		nextbtn.hide()

# STEP 3: Activated right after Software Engineer click processes
func _setup_ask_button_tutorial_ui():
	$Control/CanvasLayer/UI_Control/Askbutton.z_index = 5
	ask_button.border_width_bottom = 5
	ask_button.border_width_top = 5
	ask_button.border_width_left = 5
	ask_button.border_width_right = 5
	ask_button.border_color = Color("30fff0")
	
	stylebox_BtnGuess.border_color = Color("3e3e3e")
	guess_button.z_index = -1
	
	$Control/CanvasLayer/UI_Control/guessleft/Label2.text = "\n\n  PRESS THE ASK BUTTON  \n   to see your question list\n\n"
	$Control/CanvasLayer/UI_Control/Control/Sprite2D.show()
	guesslabelarrow.hide()
	askarrow.show()
	
	$Control/CanvasLayer/UI_Control/Askbutton.add_theme_stylebox_override("normal", ask_button)
	$Control/CanvasLayer/UI_Control/HBoxContainer3/Button.add_theme_stylebox_override("normal", stylebox_BtnGuess)

# STEP 4: Activated right after the highlighted question element is selected
func _setup_receptionist_tutorial_ui():
	ask_button.border_color = Color("3e3e3e")
	$Control/CanvasLayer/UI_Control/Askbutton.add_theme_stylebox_override("normal", ask_button)
	
	guess_button.z_index = 6
	stylebox_BtnGuess.border_color = Color("30fff0")
	$Control/CanvasLayer/UI_Control/HBoxContainer3/Button.add_theme_stylebox_override("normal", stylebox_BtnGuess)
	
	guesslabelarrow.show()
	$Control/CanvasLayer/UI_Control/guessleft/Label2.text = "\n\n  NOW PRESS Guess! textbox \n   type Receptionist! \n and select it\n"
	$Control/CanvasLayer/UI_Control/guessleft/Label2.add_theme_stylebox_override("normal", stylebosLabel)
