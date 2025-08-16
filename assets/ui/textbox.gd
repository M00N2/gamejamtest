extends CanvasLayer

const CHAR_READ_RATE = 0.05  # Adjusted for better timing in Godot 4

@onready var textbox_container = $TextboxContainer
@onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []
var current_tween: Tween

func _ready():
	add_to_group("textbox")  # Add this line for easy access
	print("Starting state to: State.READY")
	# Enable text wrapping on the label
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hide_textbox()
	# Remove these test messages so the textbox starts empty:
	# queue_text("First text queued up")
	# queue_text("Second text queued up")
	# queue_text("Third text queued up")
	# queue_text("Fourth text queued up")

func _process(delta):
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("interact"):
				label.visible_ratio = 1.0
				if current_tween:
					current_tween.kill()
				end_symbol.text = "v"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("interact"):
				change_state(State.READY)
				hide_textbox()
				
func queue_text(next_text):
	text_queue.push_back(next_text)

func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()
	
func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()

func display_text():
	var next_text = text_queue.pop_front()
	label.text = next_text
	label.visible_ratio = 0.0  # Start with no text visible
	change_state(State.READING)
	show_textbox()
	
	# Create a new Tween for this animation and store reference
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
