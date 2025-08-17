extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D
@onready var knock_audio: AudioStreamPlayer = $AudioStreamPlayer

var textbox
var has_been_knocked = false
var knock_timer: Timer
var current_visitor = null
var delivery_completed_today = false
var first_visitor_today = true

# New independent timing system
var next_visitor_time = 0.0  # When next visitor should arrive
var time_elapsed = 0.0       # Track time independently
var visitor_system_active = true

# Delivery person - first visitor of the day
var delivery_person = {
	"type": "delivery",
	"name": "Delivery Driver",
	"greeting": "Package delivery! Got your order right here.",
	"alt_greetings": [
		"Morning! Package for you.",
		"Delivery service! Sign here please.",
		"Got your stuff. Where do you want it?"
	],
	"personality": "professional"
}

# Friends and family who care about your wellbeing
var friends_family = [
	{
		"type": "friend",
		"name": "Sarah (Best Friend)",
		"greeting": "Hey! I brought coffee. Can I come in? You've been so quiet lately...",
		"alt_greetings": [
			"I was worried about you. Haven't seen you in forever!",
			"Okay, I'm officially concerned. Are you avoiding me?",
			"I miss hanging out. What's going on with you?"
		],
		"personality": "caring",
		"relationship": "best_friend"
	},
	{
		"type": "family",
		"name": "Mom",
		"greeting": "Sweetheart? I brought some food. You haven't been returning my calls...",
		"alt_greetings": [
			"Honey, I'm worried. Can we talk?",
			"I made too much dinner. Thought you might be hungry.",
			"Your father and I haven't heard from you. Are you okay?"
		],
		"personality": "worried_parent",
		"relationship": "parent"
	},
	{
		"type": "family", 
		"name": "Your Brother",
		"greeting": "Dude, you've been MIA. Mom's freaking out. What's up?",
		"alt_greetings": [
			"Yo, you alive in there? Everyone's worried.",
			"Mom sent me to check on you. You good?",
			"Haven't seen you online in weeks. That's not like you."
		],
		"personality": "casual_concerned",
		"relationship": "sibling"
	},
	{
		"type": "neighbor",
		"name": "Mrs. Chen (Neighbor)",
		"greeting": "Hello dear! I noticed your mail piling up. Is everything alright?",
		"alt_greetings": [
			"I haven't seen you around lately. Are you feeling well?",
			"Your packages have been sitting out there for days...",
			"I hope I'm not overstepping, but I wanted to check on you."
		],
		"personality": "kindly_nosy",
		"relationship": "neighbor"
	},
	{
		"type": "friend",
		"name": "Alex (College Friend)", 
		"greeting": "Surprise visit! I was in town and... wow, you look rough. Everything okay?",
		"alt_greetings": [
			"Long time no see! Thought I'd drop by unannounced.",
			"I was driving by and saw your car. Figured I'd say hi!",
			"Remember me? We used to hang out all the time..."
		],
		"personality": "oblivious_cheerful",
		"relationship": "distant_friend"
	}
]

var visited_today = []  # Track who's already visited

func _ready() -> void:
	# Make cursor visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	interactable.interact_name = "Check Door"
	interactable.is_interactable = true
	interactable.interact = _on_interact
	
	# Keep the old timer as backup, but use independent timing as primary
	knock_timer = Timer.new()
	knock_timer.wait_time = 8.0
	knock_timer.one_shot = true
	knock_timer.timeout.connect(_check_for_visitors)
	add_child(knock_timer)
	
	# Set up independent timing system
	time_elapsed = 0.0
	next_visitor_time = randf_range(5.0, 12.0)  # First visitor
	visitor_system_active = true
	print("Door: Independent visitor system initialized. Next visitor in ", next_visitor_time, " seconds")

# Process function runs every frame regardless of other interactions
func _process(delta):
	if not visitor_system_active:
		return
		
	time_elapsed += delta
	
	# Check if it's time for a visitor
	if time_elapsed >= next_visitor_time and not has_been_knocked:
		print("Door: Time for visitor! Elapsed: ", time_elapsed, " Target: ", next_visitor_time)
		_check_for_visitors_independent()
		
# Independent visitor check that doesn't rely on Timer
func _check_for_visitors_independent():
	print("Door: Independent visitor check. First visitor today: ", first_visitor_today)
	
	# First visitor is always delivery (if player ordered things)
	if first_visitor_today and _should_show_delivery():
		print("Door: Showing delivery person")
		_delivery_person_arrives()
		first_visitor_today = false
	else:
		first_visitor_today = false
		# Random chance for concerned friends/family
		var random_roll = randf()
		print("Door: Random roll for visitor: ", random_roll)
		if random_roll < 0.8:  # 80% chance someone visits
			print("Door: Attempting friends/family visit")
			_friends_family_arrives()
		else:
			print("Door: No visitor this time, scheduling next")
			_schedule_next_visitor_independent()

# Schedule next visitor using independent timing
func _schedule_next_visitor_independent():
	var wait_time = randf_range(10.0, 20.0)
	next_visitor_time = time_elapsed + wait_time
	print("Door: Independent scheduling - next visitor in ", wait_time, " seconds (at time ", next_visitor_time, ")")

func _check_for_visitors():
	print("Door: Checking for visitors. First visitor today: ", first_visitor_today)
	
	# First visitor is always delivery (if player ordered things)
	if first_visitor_today and _should_show_delivery():
		print("Door: Showing delivery person")
		_delivery_person_arrives()
		first_visitor_today = false
	else:
		first_visitor_today = false
		# Random chance for concerned friends/family
		var random_roll = randf()
		print("Door: Random roll for visitor: ", random_roll)
		if random_roll < 0.8:  # Increased chance to 80% for testing
			print("Door: Attempting friends/family visit")
			_friends_family_arrives()
		else:
			print("Door: No visitor this time, scheduling next")
			_schedule_next_visitor()

func _should_show_delivery() -> bool:
	# Check if player has active orders or deliveries pending
	# This connects with your partner's buying system
	var should_deliver = Stats.current_day > 1 and not delivery_completed_today
	print("Door: Should show delivery? ", should_deliver, " (day: ", Stats.current_day, ", delivery_completed: ", delivery_completed_today, ")")
	return should_deliver

func _delivery_person_arrives():
	has_been_knocked = true
	current_visitor = delivery_person.duplicate(true)
	delivery_completed_today = true
	
	# Randomize greeting for variety
	if current_visitor.alt_greetings.size() > 0:
		current_visitor.greeting = current_visitor.alt_greetings[randi() % current_visitor.alt_greetings.size()]
	
	if knock_audio:
		knock_audio.play()
	
	interactable.interact_name = "Answer Door"
	print("Delivery person at the door!")

func _friends_family_arrives():
	print("Door: Friends/family function called")
	print("Door: Visited today list: ", visited_today)
	
	# Filter out people who already visited today
	var available_visitors = []
	for visitor in friends_family:
		print("Door: Checking visitor: ", visitor.name)
		if not visited_today.has(visitor.name):
			available_visitors.append(visitor)
			print("Door: Added to available: ", visitor.name)
		else:
			print("Door: Already visited today: ", visitor.name)
	
	print("Door: Available visitors count: ", available_visitors.size())
	
	if available_visitors.is_empty():
		print("Door: No available visitors, scheduling next")
		_schedule_next_visitor()
		return
	
	has_been_knocked = true
	current_visitor = available_visitors[randi() % available_visitors.size()].duplicate(true)
	visited_today.append(current_visitor.name)
	
	print("Door: Selected visitor: ", current_visitor.name)
	
	# Use alternate greeting if they've visited before this week
	if current_visitor.alt_greetings.size() > 0 and randf() < 0.4:
		current_visitor.greeting = current_visitor.alt_greetings[randi() % current_visitor.alt_greetings.size()]
	
	if knock_audio:
		knock_audio.play()
	
	interactable.interact_name = "Answer Door"
	print(current_visitor.name + " is at the door!")

func _on_interact():
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
		if not textbox:
			return
	
	if textbox.current_state == textbox.State.READY:
		if has_been_knocked:
			_show_door_choice()
		else:
			var lonely_thoughts = [
				"The door is closed. Just how I like it.",
				"No one's coming. That's... good, right?",
				"Silence. Finally.",
				"The door keeps the world out."
			]
			textbox.queue_text(lonely_thoughts[randi() % lonely_thoughts.size()])

func _show_door_choice():
	if current_visitor.type == "delivery":
		# Delivery person - business transaction, less anxiety
		textbox.show_choices(
			"Someone's at the door. Sounds like a delivery.",
			["Answer the door", "Leave it outside"],
			_on_door_choice_made
		)
	else:
		# Friends/family - social anxiety kicks in hard
		var anxiety_thoughts = [
			"Someone's here. My chest feels tight.",
			"I can't do this. Not today.",
			"They sound concerned. That makes it worse.",
			"What if they think I'm broken?",
			"I should answer. But I can't move.",
			"They care about me. Why does that hurt?"
		]
		
		textbox.show_choices(
			anxiety_thoughts[randi() % anxiety_thoughts.size()],
			["Force yourself to answer", "Hide until they leave"],
			_on_door_choice_made
		)

func _on_door_choice_made(choice_index: int, choice_text: String):
	await get_tree().process_frame
	
	if choice_index == 0:  # Answer
		_answer_door()
	else:  # Ignore/Hide
		_ignore_visitor()

func _answer_door():
	if current_visitor.type == "delivery":
		_handle_delivery()
	else:
		_handle_social_visit()

func _handle_delivery():
	# Delivery is straightforward - minimal energy cost
	if Stats.do_action(1):
		# Increase moral for successful social interaction
		Stats.happiness += 1
		
		textbox.queue_text("You open the door just enough to see out.")
		textbox.queue_text('"' + current_visitor.greeting + '"')
		textbox.queue_text("You nod and accept the packages quickly.")
		textbox.queue_text("They seem in a hurry too. Perfect.")
		textbox.queue_text("The door closes. Transaction complete.")
		textbox.queue_text("Moral +1 (Social interaction)")
		
		print("Door: Delivery interaction completed. Moral +1")
	else:
		textbox.queue_text("You're too drained to even answer the door.")
		textbox.queue_text("You'll grab the packages later.")
		Stats.denied()
	
	_reset_door()

func _handle_social_visit():
	# Social visits are draining but can be rewarding
	if Stats.do_action(3):  # Higher cost than delivery
		# Base moral increase for any successful social interaction
		Stats.happiness += 1
		
		textbox.queue_text("You take several deep breaths.")
		textbox.queue_text("Your hand shakes as you reach for the door.")
		textbox.queue_text("You open it slowly.")
		textbox.queue_text('"' + current_visitor.greeting + '"')
		
		# Different outcomes based on relationship and personality
		match current_visitor.personality:
			"caring":
				textbox.queue_text("Their eyes are full of genuine concern.")
				textbox.queue_text("You feel seen in a way that's both scary and comforting.")
				textbox.queue_text("The conversation is hard, but healing.")
				Stats.happiness += 4  # Additional bonus (total +5)
				Stats.add_good_path(2)
				
			"worried_parent":
				textbox.queue_text("You can see how much they've been worried.")
				textbox.queue_text("Guilt washes over you for making them suffer.")
				textbox.queue_text("But their love is unconditional. Always has been.")
				Stats.happiness += 3  # Additional bonus (total +4)
				Stats.add_good_path(2)
				
			"casual_concerned":
				textbox.queue_text("They try to keep things light, but you can tell they're worried.")
				textbox.queue_text("The familiar banter almost makes you feel normal.")
				textbox.queue_text("For a moment, you remember who you used to be.")
				Stats.happiness += 2  # Additional bonus (total +3)
				Stats.add_good_path(1)
				
			"kindly_nosy":
				textbox.queue_text("They mean well, but ask too many questions.")
				textbox.queue_text("You give short answers and feel judged.")
				textbox.queue_text("Still, someone cared enough to check on you.")
				Stats.happiness += 1  # Additional bonus (total +2)
				Stats.add_good_path(1)
				
			"oblivious_cheerful":
				textbox.queue_text("They don't seem to notice how much you're struggling.")
				textbox.queue_text("Their cheerfulness feels overwhelming.")
				textbox.queue_text("But maybe pretending to be okay for a bit helps.")
				# No additional bonus, just the base +1
		
		textbox.queue_text("After they leave, you're exhausted but feel slightly more connected to the world.")
		textbox.queue_text("Moral +1 (Social interaction)")
		print("Door: Social interaction completed. Base moral +1, plus personality bonus")
	else:
		textbox.queue_text("You want to answer. You really do.")
		textbox.queue_text("But you have nothing left to give.")
		textbox.queue_text("You stay silent, hoping they'll understand.")
		Stats.denied()
		Stats.add_bad_path(1)
	
	_reset_door()

func _ignore_visitor():
	has_been_knocked = false
	interactable.interact_name = "Check Door"
	
	if current_visitor.type == "delivery":
		textbox.queue_text("You ignore the delivery person.")
		textbox.queue_text("After a moment, you hear packages being set down.")
		textbox.queue_text("Their footsteps fade away.")
		textbox.queue_text("You'll grab everything later when it's safe.")
		# Packages still delivered, just left outside
	else:
		# Ignoring friends/family has consequences
		Stats.add_bad_path(2)
		
		textbox.queue_text("You press yourself against the wall.")
		textbox.queue_text("Your heart pounds as they knock again.")
		textbox.queue_text('"I know you\'re in there. I\'m worried about you."')
		textbox.queue_text("The guilt is crushing, but you can't move.")
		textbox.queue_text("Eventually, the knocking stops.")
		textbox.queue_text("Silence. They've given up on you.")
		textbox.queue_text("Again.")
		
		# Different guilt based on relationship
		match current_visitor.relationship:
			"parent":
				textbox.queue_text("Your parent just wanted to help.")
				textbox.queue_text("You've hurt them by shutting them out.")
				Stats.happiness -= 2
			"best_friend":
				textbox.queue_text("Your best friend came all this way.")
				textbox.queue_text("They probably think you hate them now.")
				Stats.happiness -= 1
			"sibling":
				textbox.queue_text("They'll probably tell everyone you ignored them.")
				textbox.queue_text("More family drama. Great.")
			_:
				textbox.queue_text("Another relationship slowly dying.")
				textbox.queue_text("This is how you lose everyone.")
	
	await get_tree().create_timer(4.0).timeout
	_reset_door()

func _schedule_next_visitor():
	# Legacy function - now using independent timing
	print("Door: Legacy timer function called - using independent timing instead")
	_schedule_next_visitor_independent()

func _reset_door():
	has_been_knocked = false
	interactable.interact_name = "Check Door"
	current_visitor = null
	print("Door: Reset - ready for next visitor")
	
	# Schedule potential next visitor using independent timing
	_schedule_next_visitor_independent()

# Call this from your day management system
func new_day_started():
	print("Door: New day started")
	delivery_completed_today = false
	first_visitor_today = true
	visited_today.clear()
	
	# Reset independent timing for new day
	time_elapsed = 0.0
	next_visitor_time = randf_range(3.0, 8.0)  # First visitor of the day
	visitor_system_active = true
	
	print("Door: Reset visited_today, first_visitor_today = true")
	print("Door: Independent timing reset. Next visitor in ", next_visitor_time, " seconds")

# Pause/resume visitor system (useful for cutscenes, etc.)
func pause_visitor_system():
	visitor_system_active = false
	print("Door: Visitor system paused")

func resume_visitor_system():
	visitor_system_active = true
	print("Door: Visitor system resumed")

# Skip to next visitor immediately (good for testing)
func skip_to_next_visitor():
	next_visitor_time = time_elapsed
	print("Door: Skipping to next visitor immediately")

# Force any random visitor to appear immediately
func force_random_visitor():
	print("Door: Forcing random visitor")
	# Reset timing to trigger visitor immediately
	next_visitor_time = time_elapsed
	
	# Pick random visitor (delivery or friends/family)
	if randf() < 0.3 and not delivery_completed_today:
		# 30% chance for delivery if not done today
		_delivery_person_arrives()
	else:
		# Otherwise friends/family
		_force_friends_family()

# Force friends/family visitor specifically  
func force_friends_family():
	print("Door: Forcing friends/family visitor")
	next_visitor_time = time_elapsed
	_force_friends_family()

func _force_friends_family():
	# Get all available visitors (ignore visited_today for forced visits)
	var available_visitors = friends_family.duplicate(true)
	
	if available_visitors.is_empty():
		print("Door: No friends/family available")
		return
	
	has_been_knocked = true
	current_visitor = available_visitors[randi() % available_visitors.size()].duplicate(true)
	
	# Use alternate greeting sometimes
	if current_visitor.alt_greetings.size() > 0 and randf() < 0.5:
		current_visitor.greeting = current_visitor.alt_greetings[randi() % current_visitor.alt_greetings.size()]
	
	if knock_audio:
		knock_audio.play()
	
	interactable.interact_name = "Answer Door"
	print("Door: Forced visitor - " + current_visitor.name + " is at the door!")

# Force delivery person specifically
func force_delivery():
	print("Door: Forcing delivery person")
	next_visitor_time = time_elapsed
	_delivery_person_arrives()

# Force a specific visitor by name
func force_specific_visitor(visitor_name: String):
	print("Door: Forcing specific visitor: ", visitor_name)
	next_visitor_time = time_elapsed
		
	# Check delivery first
	if visitor_name == "Delivery Driver" or visitor_name == "delivery":
		_delivery_person_arrives()
		return
	
	# Check friends/family
	for visitor in friends_family:
		if visitor.name == visitor_name or visitor.name.to_lower().contains(visitor_name.to_lower()):
			current_visitor = visitor.duplicate(true)
			has_been_knocked = true
			if knock_audio:
				knock_audio.play()
			interactable.interact_name = "Answer Door"
			print("Door: Forced specific visitor - " + current_visitor.name + " is at the door!")
			return
	
	print("Door: Visitor not found: ", visitor_name)

# Make visitors come much more frequently
func set_frequent_visitors(enabled: bool):
	if enabled:
		print("Door: Enabling frequent visitors")
		next_visitor_time = time_elapsed + randf_range(2.0, 5.0)  # Very frequent
	else:
		print("Door: Disabling frequent visitors")
		next_visitor_time = time_elapsed + randf_range(20.0, 45.0)  # Normal timing

# Remove all conditions - visitors ALWAYS come when timer hits
func enable_guaranteed_visitors():
	print("Door: Enabling guaranteed visitors - mode not implemented with independent timing")
	# Note: With independent timing, we can just set frequent visitors instead
	set_frequent_visitors(true)
