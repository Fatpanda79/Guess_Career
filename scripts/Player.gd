extends MeshInstance3D

# You can adjust this in the Inspector to make the animation faster or slower
@export var animation_duration: float = 2.0

func _ready():
	# Create a tween and set it to loop infinitely
	var tween = create_tween().set_loops()
	
	# Optional: Smooth out the animation so it eases in and out instead of moving rigidly
	tween.set_trans(Tween.TRANS_SINE)
	
	# Step 1: Scale the Y axis to 1.2 over the set duration
	tween.tween_property(self, "scale:y", 1.1, animation_duration)
	
	# Step 2: Scale the Y axis back down to 1.0 over the set duration
	tween.tween_property(self, "scale:y", 1.0, animation_duration)

# We don't need _process for Tweens!
