extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D

var textbox  # Reference to your textbox

func _ready() -> void:
	print("Bed script: _ready() called")
	interactable.interact = _on_interact

func _on_interact():
	print("Bed script: _on_interact() called!")
	
	# Try to find textbox each time instead of only in _ready()
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
		if not textbox:
			# Try direct path approach
			textbox = get_node("../Textbox")  # Adjust this path if needed
	
	if textbox:
		# Only interact if the textbox is in READY state (not currently showing text)
		if textbox.current_state == textbox.State.READY:
			print("Bed script: Found textbox! Calling queue_text()")
			textbox.queue_text("I'm not tired right now.")
		else:
			print("Bed script: Textbox is busy, ignoring interaction")
	else:
		print("Bed script: Still can't find textbox")
		print("I'm not tired right now")
