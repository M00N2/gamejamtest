extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D
@onready var knock_audio: AudioStreamPlayer = $AudioStreamPlayer

var textbox
var has_been_knocked = false
var knock_timer: Timer

func _ready() -> void:
	interactable.interact_name = "Check Door"
	interactable.is_interactable = true
	interactable.interact = _on_interact
	
	# Create a timer for automatic knocking
	knock_timer = Timer.new()
	knock_timer.wait_time = 5.0
	knock_timer.one_shot = true
	knock_timer.timeout.connect(_someone_knocks)
	add_child(knock_timer)
	knock_timer.start()

func _someone_knocks():
	has_been_knocked = true
	print("*KNOCK KNOCK KNOCK*")
	
	# Play the door knock sound
	if knock_audio:
		knock_audio.play()
	
	# Change interaction text
	interactable.interact_name = "Answer Door"
	
	print("Someone is at the door!")

func _on_interact():
	print("Door: _on_interact() called!")
	
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
		if textbox:
			print("Door: Found textbox!")
		else:
			print("Door: ERROR - No textbox found!")
			return
	
	if textbox.current_state == textbox.State.READY:
		if has_been_knocked:
			print("Door: Someone is knocking, showing choices...")
			
			textbox.show_choices(
				"Someone is knocking at the door. What do you do?",
				["Answer the door", "Ignore it"],
				_on_door_choice_made
			)
		else:
			print("Door: No one at the door")
			textbox.queue_text("The door is closed. No one seems to be there.")
	else:
		print("Door: Textbox is busy")

func _on_door_choice_made(choice_index: int, choice_text: String):
	print("Door: Player chose ", choice_index, " - ", choice_text)
	
	if textbox:
		if choice_index == 0:  # Answer the door
			print("Door: Player answered the door")
			textbox.queue_text("You open the door...")
			textbox.queue_text("A delivery person hands you a package.")
			textbox.queue_text("'Thanks for ordering! Have a great day!' they say.")
			textbox.queue_text("They walk away quickly.")
			_reset_door()
		else:  # Ignore it
			print("Door: Player ignored the door")
			has_been_knocked = false  # Person is "leaving" - no more choices
			interactable.interact_name = "Check Door"  # Change interaction back
			
			textbox.queue_text("You decide to ignore the knocking.")
			textbox.queue_text("The knocking continues for a moment...")
			textbox.queue_text("After a while, it stops.")
			textbox.queue_text("You hear footsteps walking away.")
			
			# Start the timer for next visitor after dialogue
			await get_tree().create_timer(3.0).timeout
			knock_timer.wait_time = randf_range(10.0, 30.0)
			knock_timer.start()

func _reset_door():
	has_been_knocked = false
	interactable.interact_name = "Check Door"
	print("Door: Reset - ready for next visitor")
	
	# Set up another knock later
	knock_timer.wait_time = randf_range(10.0, 30.0)
	knock_timer.start()
