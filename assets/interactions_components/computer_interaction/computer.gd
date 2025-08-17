extends StaticBody2D

@onready var desktop_ui: CanvasLayer = $"../desktop_ui"
@onready var exit_button: Button = $"../desktop_ui/desktop/ExitButton" 
@onready var shop_button: TextureButton = $"../desktop_ui/desktop/shop"
@onready var game_button: TextureButton = $"../desktop_ui/desktop/game"
@onready var news_button: TextureButton = $"../desktop_ui/desktop/news"
@onready var work_button: TextureButton = $"../desktop_ui/desktop/work"

@onready var action_panel: Control = $"../desktop_ui/desktop/ActionPanel"
@onready var action_sprite: Sprite2D = action_panel.get_node("Sprite")
@onready var action_label: Label = $"../desktop_ui/desktop/ActionPanel/Label"
@onready var action_close: Button = action_panel.get_node("Close")

@onready var Shop: Control = $"../desktop_ui/desktop/Shop"
@onready var money_label: Label = $"../desktop_ui/desktop/Shop/money"
@onready var food_button: TextureButton = $"../desktop_ui/desktop/Shop/food"
@onready var water_button: TextureButton = $"../desktop_ui/desktop/Shop/water"
@onready var book_button: TextureButton = $"../desktop_ui/desktop/Shop/books"

@onready var interactable: Area2D = $Interactable
const CHAR_READ_RATE = 0.05
const wfcost = 40
const bcost = 70

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  
	interactable.interact_name = "Use Computer"
	interactable.is_interactable = true
	interactable.interact = _on_interact
	action_label.scale = Vector2(0.12, 0.12)
	action_panel.visible = false
	Shop.scale = Vector2(0.9, 0.9)
	Shop.visible = false

	#exit
	if exit_button:
		exit_button.pressed.connect(_close_computer)

	# Action buttons
	if shop_button:
		shop_button.pressed.connect(func(): C_do_action("shop"))
	if game_button:
		game_button.pressed.connect(func(): C_do_action("game"))
	if news_button:
		news_button.pressed.connect(func(): C_do_action("news"))
	if work_button:
		work_button.pressed.connect(func(): C_do_action("work"))
	
	food_button.pressed.connect(func(): _buy_item("food", wfcost))
	water_button.pressed.connect(func(): _buy_item("water", wfcost))
	book_button.pressed.connect(func(): _buy_item("book", bcost))
	
	action_close.pressed.connect(_close_action_panel)
	
func _close_action_panel() -> void:
	action_panel.visible = false
	Shop.visible = false

func show_action_message(message: String) -> void:
	action_label.text = message
	action_label.visible_ratio = 0.0
	action_panel.visible = true
	
	# Animate the reveal
	var tween := create_tween()
	tween.tween_property(
		action_label, 
		"visible_ratio", 
		1.0, 
		message.length() * CHAR_READ_RATE
	)

func C_do_action(action: String) -> void:
	var cost := 0
	
	match action:
		"shop":
			cost = 0
		"game":
			cost = 1
		"news":
			cost = 1
		"work":
			cost = 2
	
	if Stats.do_action(cost):
		match action:
			"shop":
				show_action_message("You browse the shop. Items will be delivered tomorrow.")
				_open_shop()
				Stats.add_bad_path(0) # shop costs nothing
			"game":
				show_action_message("You play games for a while. Your happiness rises a little.") 
				Stats.happiness += 2
				Stats.add_bad_path(1)
			"news":
				show_action_message("You read the news, fear the world.") 
				Stats.add_good_path(1)
			"work":
				show_action_message("You do some freelance work. You earn money, but at a cost.") 
				Stats.money += 50
				Stats.add_bad_path(2)
		action_panel.visible = true
	else:
		Shop.visible = false
		action_panel.visible = false
		_close_computerS()

func _open_shop() -> void:
	action_panel.visible = true
	Shop.visible = true
	_show_money()

func _buy_item(item: String, cost: int) -> void:
	if Stats.money >= cost:
		Stats.money -= cost
		Stats.Delivery.append(item)
		show_action_message("You bought " + item + ". It will be delivered tomorrow.")
	else:
		show_action_message("I don't have enough money for " + item + ".")
	_show_money()

func _show_money()-> void:
	money_label.text = ("$" + str(Stats.money))

func _process(delta: float) -> void:
	if desktop_ui.visible and Input.is_action_just_pressed("exit"):
		_close_computer()

func _on_interact() -> void:
	_open_computer()

func _open_computer() -> void:
	desktop_ui.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	desktop_ui.process_mode = Node.PROCESS_MODE_ALWAYS

func _close_computer() -> void:
	Shop.visible = false
	action_panel.visible = false
	desktop_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	desktop_ui.process_mode = Node.PROCESS_MODE_INHERIT
	
func _close_computerS() -> void:
	Shop.visible = false
	action_panel.visible = false
	desktop_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	desktop_ui.process_mode = Node.PROCESS_MODE_INHERIT
	Stats.denied()
