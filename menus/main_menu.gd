extends Control

@onready var _settings_button : Button = $"%Settings"
@onready var _exit_button     : Button = $"%Exit"
#-------------------------------------------------------------------------------
@onready var _main_menu       : Control = $"%MainMenu"

func _ready() -> void:
    _exit_button.pressed.connect(try_exit)
    _settings_button.pressed.connect(toggle_settings.bind(true))
    global_MenuManager.settings_menu.close.connect(toggle_settings.bind(false))

func try_exit() -> void:
    get_tree().quit()

func toggle_settings(toggle_on : bool) -> void:
    _main_menu.visible     = !toggle_on
