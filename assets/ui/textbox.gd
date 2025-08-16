extends CanvasLayer

const CHAR_READ_RATE = 0.05

@onready var textbox_container = $TextboxContainer
@onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label

# Choice system components
@onready var choice_container = $ChoiceContainer
@onready var choice_button_1 = $ChoiceContainer/VBoxContainer/Choice1
@onready var choice_button_2 = $ChoiceContainer/VBoxContainer/Choice2

enum State {
	READY,
	READING,
	FINISHED,
	CHOOSING
}

var current_state = State.READY
var text_queue = []
var current_tween: Tween
var current_choices = []
var choice_callback: Callable

func _ready():
	add_to_group("textbox")
	print("Starting state to: State.READY")
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hide_textbox()
	
	# Connect choice buttons with null checks
	if choice_button_1:
		choice_button_1.pressed.connect(_on_choice_selected.bind(0))
		print("Connected choice_button_1")
	else:
		print("ERROR: choice_button_1 is null!")
		
	if choice_button_2:
		choice_button_2.pressed.connect(_on_choice_selected.bind(1))
		print("Connected choice_button_2")
	else:
		print("ERROR: choice_button_2 is null!")

func _process(delta):
	match current_state:
		State.READY:
			pass
		State.READING:
			if Input.is_action_just_pressed("interact"):
				label.visible_ratio = 1.0
				if current_tween:
					current_tween.kill()
				end_symbol.text = "v"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("interact"):
				if !text_queue.is_empty():
					display_text()
				else:
					change_state(State.READY)
					hide_textbox()
		State.CHOOSING:
			# Just wait for mouse clicks on buttons
			pass

func queue_text(next_text):
	text_queue.push_back(next_text)
	if current_state == State.READY:
		display_text()

func show_choices(question: String, choices: Array, callback: Callable):
	print("show_choices called with: ", question)
	print("Callback function: ", callback)
	
	text_queue.clear()
	current_choices = choices
	choice_callback = callback
	
	label.text = question
	label.visible_ratio = 1.0
	show_textbox()
	
	# Set up buttons
	if choices.size() >= 1 and choice_button_1 != null:
		choice_button_1.text = choices[0]
		choice_button_1.visible = true
		print("Set choice 1 to: ", choices[0])
	
	if choices.size() >= 2 and choice_button_2 != null:
		choice_button_2.text = choices[1]
		choice_button_2.visible = true
		print("Set choice 2 to: ", choices[1])
	
	if choice_container != null:
		choice_container.show()
		print("Showing choice container")
	
	end_symbol.text = ""
	change_state(State.CHOOSING)

func _on_choice_selected(choice_index: int):
	print("Choice selected: ", choice_index)
	print("Choice callback valid: ", choice_callback.is_valid())
	
	# Hide choices but DON'T hide textbox yet
	if choice_container:
		choice_container.hide()
	if choice_button_1:
		choice_button_1.visible = false
	if choice_button_2:
		choice_button_2.visible = false
	
	# Call the callback
	if choice_callback.is_valid() and choice_index < current_choices.size():
		print("Calling callback with: ", choice_index, current_choices[choice_index])
		choice_callback.call(choice_index, current_choices[choice_index])
	else:
		print("ERROR: Invalid callback or choice index")
	
	change_state(State.READY)
	# DON'T call hide_textbox() here - let the callback handle new text

func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()
	if choice_container:
		choice_container.hide()
	
func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()

func display_text():
	var next_text = text_queue.pop_front()
	label.text = next_text
	label.visible_ratio = 0.0
	change_state(State.READING)
	show_textbox()
	
	current_tween = create_tween()
	current_tween.tween_property(label, "visible_ratio", 1.0, len(next_text) * CHAR_READ_RATE)
	current_tween.tween_callback(_on_tween_completed)

func _on_tween_completed():
	change_state(State.FINISHED)
	end_symbol.text = "v"

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changed state to: State.READY")
		State.READING:
			print("Changed state to: State.READING")
		State.FINISHED:
			print("Changed state to: State.FINISHED")
		State.CHOOSING:
			print("Changed state to: State.CHOOSING")
