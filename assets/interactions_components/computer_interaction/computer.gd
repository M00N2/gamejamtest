extends StaticBody2D

@onready var desktop_ui: CanvasLayer = $"../desktop_ui"  # Adjust path as needed
@onready var exit_button: Button = $"../desktop_ui/desktop/ExitButton"  # Adjust path as needed  
@onready var textbox: Node = get_tree().get_first_node_in_group("textbox")
@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  
	interactable.interact_name = "Use Computer"
	interactable.is_interactable = true
	interactable.interact = _on_interact
	if exit_button:
		exit_button.pressed.connect(_close_computer)

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
	desktop_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	desktop_ui.process_mode = Node.PROCESS_MODE_INHERIT
	# ✅ Close textbox properly
	if textbox:
		if textbox.has_method("close"):  # If textbox script has a close method
			textbox.call("close")
		elif "visible" in textbox:
			textbox.visible = false
