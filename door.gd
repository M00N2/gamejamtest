extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D
@onready var knock_audio: AudioStreamPlayer = $AudioStreamPlayer

var textbox
var has_been_knocked = false
var knock_timer: Timer
var current_trader = null

# Different trader types with more personality
var traders = [
	{
		"name": "Food Vendor",
		"greeting": "Hey there! Beautiful day, isn't it? I've got some fresh food if you're interested!",
		"item": "food",
		"price": 10,
		"amount": 3,
		"personality": "overly_friendly"
	},
	{
		"name": "Water Delivery",
		"greeting": "Water delivery. You ordered this, right? Look, I'm in a hurry...",
		"item": "water", 
		"price": 8,
		"amount": 4,
		"personality": "impatient"
	},
	{
		"name": "General Supplier",
		"greeting": "I've got supplies. Food, water. Cash only. You buying or not?",
		"item": "both",
		"food_price": 12,
		"water_price": 10,
		"food_amount": 2,
		"water_amount": 3,
		"personality": "blunt"
	}
]

func _ready() -> void:
	interactable.interact_name = "Check Door"
	interactable.is_interactable = true
	interactable.interact = _on_interact
	
	knock_timer = Timer.new()
	knock_timer.wait_time = 8.0
	knock_timer.one_shot = true
	knock_timer.timeout.connect(_someone_knocks)
	add_child(knock_timer)
	knock_timer.start()

func _someone_knocks():
	has_been_knocked = true
	print("*KNOCK KNOCK KNOCK*")
	
	current_trader = traders[randi() % traders.size()]
	
	if knock_audio:
		knock_audio.play()
	
	interactable.interact_name = "Answer Door"
	print("A " + current_trader.name + " is at the door!")

func _on_interact():
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
		if not textbox:
			return
	
	if textbox.current_state == textbox.State.READY:
		if has_been_knocked:
			# Character's internal anxiety about social interaction
			var anxiety_thoughts = [
				"Someone's at the door. My heart is already racing.",
				"I wasn't expecting anyone. I hate unexpected visitors.",
				"Do I have to deal with this right now?",
				"Maybe if I'm quiet, they'll go away."
			]
			
			textbox.show_choices(
				anxiety_thoughts[randi() % anxiety_thoughts.size()],
				["Answer", "Hide"],
				_on_door_choice_made
			)
		else:
			textbox.queue_text("The door is closed.")
			textbox.queue_text("Just how I like it.")

func _on_door_choice_made(choice_index: int, choice_text: String):
	await get_tree().process_frame
	
	if choice_index == 0:  # Answer the door
		print("Door: Player answered the door")
		_meet_trader()
	else:  # Hide and wait
		print("Door: Player ignored the door")
		_ignore_trader()

func _meet_trader():
	if Stats.do_action(2):  # Costs energy to socialize
		Stats.happiness += 2  # But helps mental health
		Stats.add_good_path(1)
		
		textbox.queue_text("You take a deep breath and open the door.")
		textbox.queue_text("The sunlight feels too bright.")
		textbox.queue_text('"' + current_trader.greeting + '"')
		
		# Character's internal reaction based on trader personality
		match current_trader.personality:
			"overly_friendly":
				textbox.queue_text("Their enthusiasm is overwhelming.")
				textbox.queue_text("You force a weak smile.")
			"impatient":
				textbox.queue_text("They seem stressed. You can relate.")
				textbox.queue_text("At least they want this over quickly too.")
			"blunt":
				textbox.queue_text("Direct. No small talk. You appreciate that.")
		
		# Show trading options
		if current_trader.item == "food":
			_show_food_trade()
		elif current_trader.item == "water":
			_show_water_trade()
		else:
			_show_general_trade()
	else:
		textbox.queue_text("You're too drained to deal with people right now.")
		textbox.queue_text("You pretend you're not home.")
		Stats.denied()
		_reset_door()

func _show_food_trade():
	textbox.queue_text('"I have ' + str(current_trader.amount) + ' portions for $' + str(current_trader.price) + '."')
	textbox.queue_text("You need food, but talking to strangers is exhausting.")
	
	textbox.show_choices(
		"What do you do?",
		["Buy food (draining)", "Politely decline"],
		_on_trade_choice_made
	)

func _show_water_trade():
	textbox.queue_text('"' + str(current_trader.amount) + ' bottles for $' + str(current_trader.price) + '."')
	textbox.queue_text("You're thirsty, but this interaction feels so forced.")
	
	textbox.show_choices(
		"What do you do?",
		["Buy water (draining)", "Politely decline"],
		_on_trade_choice_made
	)

func _show_general_trade():
	textbox.queue_text('"Food: ' + str(current_trader.food_amount) + ' for $' + str(current_trader.food_price) + '"')
	textbox.queue_text('"Water: ' + str(current_trader.water_amount) + ' for $' + str(current_trader.water_price) + '"')
	textbox.queue_text("You just want this conversation to end.")
	
	textbox.show_choices(
		"What do you need most?",
		["Food (I guess)", "Water (I suppose)"],
		_on_general_trade_made
	)

func _on_trade_choice_made(choice_index: int, choice_text: String):
	await get_tree().process_frame
	
	if choice_index == 0:  # Buy item
		if current_trader.item == "food":
			_buy_food(current_trader.price, current_trader.amount)
		elif current_trader.item == "water":
			_buy_water(current_trader.price, current_trader.amount)
	else:  # Decline
		textbox.queue_text('"Oh... okay. No problem."')
		textbox.queue_text("They look confused by your awkwardness.")
		textbox.queue_text("You close the door before it gets more uncomfortable.")
	
	_reset_door()

func _on_general_trade_made(choice_index: int, choice_text: String):
	await get_tree().process_frame
	
	if choice_index == 0:
		_buy_food(current_trader.food_price, current_trader.food_amount)
	else:
		_buy_water(current_trader.water_price, current_trader.water_amount)
	
	_reset_door()

func _buy_food(price: int, amount: int):
	if Stats.money >= price:
		Stats.money -= price
		Stats.food += amount
		textbox.queue_text("You hand over the money without making eye contact.")
		textbox.queue_text("They give you the food and seem to want to chat.")
		textbox.queue_text("You mumble 'thanks' and start closing the door.")
		textbox.queue_text("Food: +" + str(amount) + " | Money: $" + str(Stats.money))
	else:
		textbox.queue_text('"I... I don\'t have enough money."')
		textbox.queue_text("The embarrassment is crushing.")
		textbox.queue_text("You close the door quickly.")

func _buy_water(price: int, amount: int):
	if Stats.money >= price:
		Stats.money -= price
		Stats.water += amount
		textbox.queue_text("You exchange money for water as quickly as possible.")
		textbox.queue_text("They try to make small talk about the weather.")
		textbox.queue_text("You nod uncomfortably and retreat inside.")
		textbox.queue_text("Water: +" + str(amount) + " | Money: $" + str(Stats.money))
	else:
		textbox.queue_text('"Sorry, I can\'t afford it right now."')
		textbox.queue_text("Your voice comes out quieter than intended.")
		textbox.queue_text("You feel like you've failed at a basic human interaction.")

func _ignore_trader():
	has_been_knocked = false
	interactable.interact_name = "Check Door"
	Stats.add_bad_path(1)  # Isolation is bad for mental health
	
	textbox.queue_text("You stay perfectly still.")
	textbox.queue_text("Maybe they'll think no one's home.")
	textbox.queue_text("The knocking continues. Your anxiety builds.")
	textbox.queue_text("Finally, silence. They've given up.")
	textbox.queue_text("Relief floods through you, followed by guilt.")
	textbox.queue_text("You needed those supplies, but talking to people is just... hard.")
	
	await get_tree().create_timer(3.0).timeout
	knock_timer.wait_time = randf_range(15.0, 25.0)
	knock_timer.start()

func _reset_door():
	has_been_knocked = false
	interactable.interact_name = "Check Door"
	current_trader = null
	print("Door: Reset - ready for next visitor")
	
	knock_timer.wait_time = randf_range(15.0, 25.0)
	knock_timer.start()
