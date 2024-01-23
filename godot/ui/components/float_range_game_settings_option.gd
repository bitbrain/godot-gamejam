extends HSlider

@export var property:String = ""

var initialised = false

func _ready():
	value = UserSettings.get_value(property)

func _on_float_range_game_settings_option_value_changed(val):
	if !initialised:
		initialised = true
	UserSettings.set_value(property, val)
