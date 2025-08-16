extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var textbox

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	print("Bed: _on_interact() called!")
	
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
		if textbox:
			print("Bed: Found textbox!")
		else:
			print("Bed: ERROR - No textbox found!")
			return
	
	if textbox.current_state == textbox.State.READY:
		print("Bed: Textbox is ready, showing choices...")
		if audio_player:
			audio_player.play()
		
		textbox.show_choices(
			"What do you want to do with the bed?",
			["Sleep", "Just look"],
			_on_bed_choice_made
		)
	else:
		print("Bed: Textbox is busy, state: ", textbox.current_state)

func _on_bed_choice_made(choice_index: int, choice_text: String):
	print("Bed: Choice callback called! Index: ", choice_index, " Text: ", choice_text)
	
	if textbox:
		if choice_index == 0:  # Sleep
			print("Bed: Player chose to sleep")
			textbox.queue_text("You decide to take a nap...")
			textbox.queue_text("ZZZ...")
		else:  # Just look
			print("Bed: Player chose to just look")
			textbox.queue_text("The bed looks comfortable.")
			textbox.queue_text("Maybe later.")
	else:
		print("Bed: ERROR - No textbox when processing choice!")
