extends CenterContainer

signal game_exited

@onready var resume_button := %ResumeButton
@onready var settings_button := %SettingsButton
@onready var exit_button := %ExitButton
@onready var settings_container := %SettingsContainer
@onready var menu_container := %MenuContainer
@onready var back_button := %BackButton

func _ready() -> void:
	resume_button.pressed.connect(_resume)
	settings_button.pressed.connect(_settings)
	exit_button.pressed.connect(_exit)
	back_button.pressed.connect(_pause_menu)
	
func grab_button_focus() -> void:
	resume_button.grab_focus()
	
func _resume() -> void:
	get_tree().paused = false
	visible = false
	
	
func _settings() -> void:
	menu_container.visible = false
	settings_container.visible = true
	back_button.grab_focus()
	
func _exit() -> void:
	game_exited.emit()
	get_tree().quit()
	
func _pause_menu() -> void:
	settings_container.visible = false
	menu_container.visible = true
	settings_button.grab_focus()
	
func _unhandled_input(event):
	if event.is_action_pressed("pause") and visible:
		get_viewport().set_input_as_handled()
		if menu_container.visible:
			_resume()
		if settings_container.visible:
			_pause_menu()
