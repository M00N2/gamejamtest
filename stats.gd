extends Node

# Shown stats
var happiness: int = 2
var hunger: int = 5
var thirst: int = 6
var money: int = 0

# Hidden stats
var action_points: int = 11
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
		action_points = 10

	# Deduct resources
	food -= food_consumption
	water -= water_consumption
	happiness -= HAPPINESS_DAILY_LOSS

	# Check if game should end
	if food < 0 or water < 0:
		return
		# trigger_bad_ending_1()

	# Refresh actions for next day
	if happiness > 0:
		action_points = 11

	# Delivery handling
	# process_deliveries()
	
	
func do_action(cost: int) -> bool:
	if action_points >= cost:
		action_points -= cost
		return true
	else:
		return false
		
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
