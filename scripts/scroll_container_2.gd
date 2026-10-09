extends ScrollContainer

func _ready():
	# For a vertical scrollbar, set custom width (e.g., 25 pixels)
	get_v_scroll_bar().custom_minimum_size.x = 20
	
	# If you also use a horizontal scrollbar, uncomment the line below:
	# get_h_scroll_bar().custom_minimum_size.y = 25
