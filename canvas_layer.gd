extends CanvasLayer

func _ready():
	visible = false  # Start hidden

func _on_app_button_pressed():
	$MyAppWindow.visible = true

func _on_app_window_close_pressed():
	$MyAppWindow.visible = false
