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
@onready var textbox: Node = get_tree().get_first_node_in_group("textbox")
@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  
	interactable.interact_name = "Use Computer"
	interactable.is_interactable = true
	interactable.interact = _on_interact
	action_label.scale = Vector2(0.12, 0.12)
	action_panel.visible = false

	
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
	
	action_close.pressed.connect(_close_action_panel)

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
				action_label.text = "You browse the shop. Items will be delivered tomorrow."
				#action_sprite.texture = preload("res://assets/desktop/desktop.png")
				Stats.add_bad_path(0) # shop costs nothing
			"game":
				action_label.text = "You play games for a while. Your happiness rises a little."
				#action_sprite.texture = preload("res://assets/desktop/desktop.png")
				Stats.happiness += 2
				Stats.add_bad_path(1)
			"news":
				action_label.text = "You read the news. It gives you insight into your state of mind."
				#action_sprite.texture = preload("res://assets/desktop/desktop.png")
				Stats.add_good_path(1)
			"work":
				action_label.text = "You do some freelance work. You earn money, but at a cost."
				#action_sprite.texture = preload("res://assets/desktop/desktop.png")
				Stats.money += 50
				Stats.add_bad_path(1)
		action_panel.visible = true
	else:
		_close_action_panel()
		_close_computerS()
		

func _close_action_panel() -> void:
	action_panel.visible = false


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
	action_panel.visible = false
	desktop_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	desktop_ui.process_mode = Node.PROCESS_MODE_INHERIT
func _close_computerS() -> void:
	action_panel.visible = false
	desktop_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	desktop_ui.process_mode = Node.PROCESS_MODE_INHERIT
	Stats.denied()
