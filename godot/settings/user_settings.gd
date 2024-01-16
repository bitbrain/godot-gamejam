extends Node

signal on_value_change(key, value)

const SECTION = "user"
const SETTINGS_FILE = "user://settings.cfg"

const MASTERVOLUME_ENABLED = "mastervolume_enabled"
const MUSICVOLUME_ENABLED = "musicvolume_enabled"
const SOUNDVOLUME_ENABLED = "soundvolume_enabled"
const MASTERVOLUME = "mastervolume"
const MUSICVOLUME = "musicvolume"
const SOUNDVOLUME = "soundvolume"
const GAME_LANGUAGE = "game_locale"

const AUDIO_BUS_MASTER = "Master"
const AUDIO_BUS_SOUND = "Sound"
const AUDIO_BUS_MUSIC = "Music"
	
var USER_SETTING_DEFAULTS = {
	MASTERVOLUME_ENABLED:true,
	MUSICVOLUME_ENABLED:true,
	SOUNDVOLUME_ENABLED:true,
	MASTERVOLUME:100,
	MUSICVOLUME:70,
	SOUNDVOLUME:100,
	GAME_LANGUAGE:"en"
}

var config:ConfigFile

func _ready():
	config = ConfigFile.new()
	config.load(SETTINGS_FILE)
	_configure_audio()
	_configure_language()
	
func set_value(key, value):
	config.set_value(SECTION, key, value)
	config.save(SETTINGS_FILE)
	if key == MASTERVOLUME:
		_update_volume(MASTERVOLUME, AUDIO_BUS_MASTER)
	if key == SOUNDVOLUME:
		_update_volume(SOUNDVOLUME, AUDIO_BUS_SOUND)
	if key == MUSICVOLUME:
		_update_volume(MUSICVOLUME, AUDIO_BUS_MUSIC)
	if key == MASTERVOLUME_ENABLED:
		_mute_bus(MASTERVOLUME_ENABLED, AUDIO_BUS_MASTER)
	if key == MUSICVOLUME_ENABLED:
		_mute_bus(MUSICVOLUME_ENABLED, AUDIO_BUS_MUSIC)
	if key == SOUNDVOLUME_ENABLED:
		_mute_bus(SOUNDVOLUME_ENABLED, AUDIO_BUS_SOUND)
	if key == GAME_LANGUAGE:
		TranslationServer.set_locale(value)
	emit_signal("on_value_change", key, value)
	
func get_value(key):
	return config.get_value(SECTION, key, _get_default(key))
	
func get_value_with_default(key, default):
	return config.get_value(SECTION, key, default)

func _get_default(key):
	if USER_SETTING_DEFAULTS.has(key):
		return USER_SETTING_DEFAULTS[key]
	return null

func _configure_audio():
	_update_volume(MASTERVOLUME, AUDIO_BUS_MASTER)
	_update_volume(MUSICVOLUME, AUDIO_BUS_MUSIC)
	_update_volume(SOUNDVOLUME, AUDIO_BUS_SOUND)
	_mute_bus(MASTERVOLUME_ENABLED, AUDIO_BUS_MASTER)
	_mute_bus(MUSICVOLUME_ENABLED, AUDIO_BUS_MUSIC)
	_mute_bus(SOUNDVOLUME_ENABLED, AUDIO_BUS_SOUND)
	
func _update_volume(property, bus):
	var current = (get_value_with_default(property, USER_SETTING_DEFAULTS[property]) -100) / 2
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), current)

func _mute_bus(property, bus):
	var enabled = get_value_with_default(property, USER_SETTING_DEFAULTS[property])
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), not enabled)

func _configure_language():
	TranslationServer.set_locale(get_value_with_default(GAME_LANGUAGE, USER_SETTING_DEFAULTS[GAME_LANGUAGE])) 
