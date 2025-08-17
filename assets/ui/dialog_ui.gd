extends CanvasLayer


@onready var box = $Box
@onready var label = $Box/Test  # Change this path to your text label node


var hide_timer: Timer

func _ready():
	hide_timer = Timer.new()
	hide_timer.one_shot = true
	hide_timer.wait_time = 2.0  # seconds before hiding
	add_child(hide_timer)
	hide_timer.connect("timeout", Callable(self, "hide_message"))

func show_message(text: String):
	label.text = text
	box.visible = true
	hide_timer.start()

func hide_message():
	box.visible = false
