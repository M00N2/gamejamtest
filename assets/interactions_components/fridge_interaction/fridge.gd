extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D

var textbox  # Reference to your textbox

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	print("Fridge script: _on_interact() called!")
	
	# Try to find textbox each time instead of only in _ready()
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
		if not textbox:
			# Try direct path approach
			textbox = get_node("../Textbox")  # Adjust this path if needed
	
	if textbox:
		# Only interact if the textbox is in READY state (not currently showing text)
		if textbox.current_state == textbox.State.READY:
			print("Fridge script: Found textbox! Calling queue_text()")
			textbox.queue_text("The fridge is empty.")
			# Or you could use multiple messages:
			# textbox.queue_text("Let me check what's inside...")
			# textbox.queue_text("The fridge is completely empty.")
		else:
			print("Fridge script: Textbox is busy, ignoring interaction")
	else:
		print("Fridge script: Still can't find textbox")
		print("You have touched the fridge")
