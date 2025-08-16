extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var textbox: Node

func _ready() -> void:
	# Hook this bed into the interaction system
	interactable.interact = _on_interact
	# Cache the textbox once
	textbox = get_tree().get_first_node_in_group("textbox")

func _on_interact() -> void:
	print("Bed: _on_interact() called!")

	if textbox == null:
		return

	# Only allow if textbox is idle
	if textbox.current_state != textbox.State.READY:
		return

	if audio_player:
		audio_player.play()

	# Show the options for the player
	textbox.show_choices(
		"What do you want to do with the bed?",
		["Sleep", "Just look"],
		Callable(self, "_on_bed_choice_made")
	)

func _on_bed_choice_made(choice_index: int, choice_text: String) -> void:
	print("Bed choice made: ", choice_index, " - ", choice_text)

	if textbox == null:
		return

	match choice_index:
		0:  # Sleep
			textbox.queue_text("You decide to take a nap...")
			textbox.queue_text("ZZZ...")
			# 👉 Add your day transition here (example: DayManager.next_day())
		1:  # Just look
			textbox.queue_text("The bed looks comfortable.")
			textbox.queue_text("Maybe later.")
