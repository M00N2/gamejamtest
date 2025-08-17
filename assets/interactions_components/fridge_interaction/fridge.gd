extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var textbox

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
	
	if textbox and textbox.current_state == textbox.State.READY:
		if audio_player:
			audio_player.play()
		
		# Check if player has any food or water
		if Stats.food <= 0 and Stats.water <= 0:
			textbox.queue_text("The fridge is empty.")
			textbox.queue_text("You have no food or water.")
			return
		
		# Always show both options plus close option
		var choice1 = "Eat (Food: " + str(Stats.food) + ")" if Stats.food > 0 else "No food available"
		var choice2 = "Drink (Water: " + str(Stats.water) + ")" if Stats.water > 0 else "No water available"
		
		textbox.show_choices(
			"What do you want to do? (Press ESC to close)",
			[choice1, choice2],
			_on_fridge_choice_made
		)

func _on_fridge_choice_made(choice_index: int, choice_text: String):
	await get_tree().process_frame
	
	if textbox:
		if choice_index == 0 and Stats.food > 0:  # Eat
			if Stats.do_action(1):
				Stats.food -= 1
				Stats.hunger = max(0, Stats.hunger - 2)
				Stats.happiness += 1
				
				textbox.queue_text("You eat some food.")
				textbox.queue_text("You feel a bit better.")
				textbox.queue_text("Food remaining: " + str(Stats.food))
				textbox.queue_text("Happiness: " + str(Stats.happiness))
			else:
				Stats.denied()
				
		elif choice_index == 1 and Stats.water > 0:  # Drink
			if Stats.do_action(1):
				Stats.water -= 1
				Stats.thirst = max(0, Stats.thirst - 2)
				Stats.happiness += 1
				
				textbox.queue_text("You drink some water.")
				textbox.queue_text("You feel refreshed.")
				textbox.queue_text("Water remaining: " + str(Stats.water))
				textbox.queue_text("Happiness: " + str(Stats.happiness))
			else:
				Stats.denied()
		else:
			# No valid option or no resources
			textbox.queue_text("=== SUPPLIES ===")
			textbox.queue_text("Food: " + str(Stats.food))
			textbox.queue_text("Water: " + str(Stats.water))
			textbox.queue_text("Action Points: " + str(Stats.action_points))
			textbox.queue_text("Day: " + str(Stats.current_day) + "/4")
