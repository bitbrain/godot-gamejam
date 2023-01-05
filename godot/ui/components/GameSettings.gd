extends VBoxContainer

@onready var master_volume_toggle = %MasterEnabledToggle
@onready var master_volume_slider = %MasterVolumeSlider
@onready var music_volume_toggle = %MusicEnabledToggle
@onready var music_volume_slider = %MusicVolumeSlider
@onready var sound_volume_toggle = %SoundEnabledToggle
@onready var sound_volume_slider = %SoundVolumeSlider
@onready var language_dropdown = %LanguageDropdown
@onready var resolution_dropdown = %ResolutionDropdown
@onready var window_mode_dropdown = %WindowModeDropdown
@onready var vsync_toggle = %VsyncEnabledToggle


func _on_master_volume_toggle_toggled(button_pressed):
	master_volume_slider.editable = button_pressed
	music_volume_slider.editable = music_volume_toggle.button_pressed and button_pressed
	sound_volume_slider.editable = sound_volume_toggle.button_pressed and button_pressed
	UserSettings.set_value("mastervolume_enabled", button_pressed)


func _on_music_enabled_toggle_toggled(button_pressed):
	music_volume_slider.editable = master_volume_toggle.button_pressed and button_pressed
	UserSettings.set_value("musicvolume_enabled", button_pressed)


func _on_sound_enabled_toggle_toggled(button_pressed):
	sound_volume_slider.editable = master_volume_toggle.button_pressed and button_pressed
	UserSettings.set_value("soundvolume_enabled", button_pressed)
