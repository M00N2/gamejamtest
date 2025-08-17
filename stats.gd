extends Node

@onready var textbox: Node = get_tree().get_first_node_in_group("textbox")
# Shown stats
var happiness: int = 2
var hunger: int = 5
var thirst: int = 6
var money: int = 50

# Hidden stats
var action_points: int = 9
var good_path_points: int = 0
var bad_path_points: int = 0

# Constants for daily requirements
const FOOD_REQ = 3
const WATER_REQ = 4

# Supplies
var food: int = 5
var water: int = 6
var books: int = 2

# Daily modifiers
const HAPPINESS_DAILY_LOSS = 2
var Delivery: Array[String] = []

var current_day = 1

func advance_day():
	current_day += 1
	print ("advancing day", current_day)
	end_day()
	
	if food <= 0 or water <= 0:
		print ("Game Over - noresources")
		return false
		
	return true

func end_day():
	# Adjust hunger/thirst based on happiness thresholds
	var food_consumption = FOOD_REQ
	var water_consumption = WATER_REQ
	if happiness < 5 and happiness > 0:
		food_consumption += 1
		water_consumption += 1
	elif happiness <= 0:
		food_consumption = 6
		water_consumption = 8
		action_points = 8

	# Deduct resources
	hunger -= food_consumption
	thirst -= water_consumption
	happiness -= HAPPINESS_DAILY_LOSS

	# Check if game should end
	if food <= 0 or water <= 0:
		return
		# trigger_bad_ending_1()

	# Refresh actions for next day
	if happiness > 0:
		action_points = 9

	# Delivery handling
	if Delivery.size() > 0:
		for i in range (Delivery.size()):
			process_deliveries(Delivery[i])
		
	Delivery = []
	
func process_deliveries(item) -> void:
		match item:
			"food":
				food += 2
			"water":
				water += 2
			"books":
				books += 1

	
func do_action(cost: int) -> bool:
	if action_points >= cost:
		action_points -= cost
		print("action_points = ", action_points)
		return true
	else:
		print("action_points = ", action_points)
		return false

func denied() -> void:
	print("_on_interact() denied!")
	
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
		if not textbox:
			textbox = get_node("../Textbox")
	
	if textbox:
		# Only play sound and show text if textbox is READY (not currently active)
		if textbox.current_state == textbox.State.READY:
			print("Found textbox! Calling queue_text()")
			#audio_player.play()  # Sound only plays when starting new dialogue
			textbox.queue_text("I'm too tired.")
		else:
			print("Textbox is busy, ignoring interaction")
			# No sound plays here - textbox handles the skipping internally
	else:
		print("Still can't find textbox")
		print("I'm too tired")
		
func get_consumption_rates() -> Dictionary:
	if happiness <= 0:
		return {"food": 6, "water": 8}
	elif happiness < 5:
		return {"food": 4, "water": 5}
	else:
		return {"food": 3, "water": 4}


func add_good_path(points: int):
	good_path_points += points
	check_endings()

func add_bad_path(points: int):
	bad_path_points += points
	check_endings()

func check_endings():
	if bad_path_points >= 10:
		return
		#trigger_bad_ending_2()
	elif good_path_points >= 12:
		return
		#trigger_good_ending()
