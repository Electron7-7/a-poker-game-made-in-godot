extends Control

signal close

const _settings_section : String = "Settings"

# TODO: Make default values but make it so you can put them here instead of in
# the GameManager class.

@onready var _confirm_clear : ConfirmationDialog = $"%ConfirmClear"
@onready var _clear_notify  : AcceptDialog       = $"%ClearNotify"
@onready var _back_button  : Button   = $"%Back"
@onready var _save_button  : Button   = $"%Save"
@onready var _clear_button : Button   = $"%Clear"
@onready var _player_name  : LineEdit = $"%PlayerName"

func get_settings() -> Dictionary[String, Variant]:
    return \
    {
        _player_name.name: _player_name.text,
    }

func _confirm_clear_settings() -> void:
    _confirm_clear.visible = true
    _confirm_clear.confirmed.connect(clear_settings)

func clear_settings() -> void:
    global_GameManager.DANGEROUS_ClearAllSaveData()
    load_settings()
    _clear_notify.visible = true

func save_settings() -> void:
    global_GameManager.SaveSection(_settings_section, get_settings())
    global_GameManager.SaveAll() # FIXME: remove from here and place before application exit, instead
    _save_button.disabled = true

func load_settings() -> void:
    var try_get_settings : SafeReturn = global_GameManager.LoadSection(_settings_section)
    if(!try_get_settings.is_ok()):
        printerr("SettingsMenu::load_settings() - Something went wrong while loading settings from the settings file!")
        return
    var data : Dictionary[String, Variant] = try_get_settings.get_data()
    _player_name.text = data.get(_player_name.name)

func _unsaved_changes(_unused) -> void:
    _save_button.disabled = false

func _ready() -> void:
    _back_button.pressed.connect(_go_back)
    _save_button.pressed.connect(save_settings)
    _clear_button.pressed.connect(_confirm_clear_settings)
    _player_name.text_changed.connect(_unsaved_changes)
    # connect all settings' relevant "-changed-" signals to "_unsaved_changes"
    load_settings()

func _go_back() -> void:
    close.emit()
