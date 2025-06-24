extends Control

signal close

const _settings_section : String = "Settings"

# TODO: Make default values but make it so you can put them here instead of in
# the GameManager class.

@onready var _confirm_clear : ConfirmationDialog = $"%ConfirmClear"
@onready var _clear_notify  : AcceptDialog       = $"%ClearNotify"
@onready var _back_button : Button = $"%Back"
@onready var _save_button : Button = $"%Save"
@onready var _clear_settings : Button = $"%ClearSettings"
@onready var _clear_backups  : Button = $"%ClearBackups"
@onready var _player_name : LineEdit = $"%PlayerName"

func get_default_settings() -> Dictionary[String, Variant]:
    return \
    {
        _player_name.name: "",
    }

func get_settings() -> Dictionary[String, Variant]:
    return \
    {
        _player_name.name: _player_name.text,
    }

func _confirm_clear_settings() -> void:
    _confirm_clear.visible = true

func clear_settings() -> void:
    global_GameManager.DANGEROUS_ClearAllSaveData()
    _clear_notify.visible = true
    _clear_settings.disabled = true
    _clear_backups.disabled = !global_GameManager.HasBackups()
    load_settings()
    global_GameManager.SaveToFile()

func _clear_backup_saves() -> void:
    global_GameManager.DANGEROUS_ClearBackupSaveData()
    _clear_backups.disabled = !global_GameManager.HasBackups()

func save_settings() -> void:
    global_GameManager.SaveSection(_settings_section, get_settings())
    global_GameManager.SaveToFile()
    _clear_backups.disabled = false
    _clear_settings.disabled = false
    _save_button.disabled = true

func load_settings() -> void:
    var loaded_settings : Dictionary[String, Variant] = global_GameManager.LoadSection(_settings_section, get_default_settings()).get_data()
    _player_name.text = loaded_settings.get(_player_name.name)

func _unsaved_changes(_unused) -> void:
    _save_button.disabled = false

func _ready() -> void:
    _back_button.pressed.connect(_go_back)
    _save_button.pressed.connect(save_settings)
    _clear_settings.pressed.connect(_confirm_clear_settings)
    _clear_backups.pressed.connect(_clear_backup_saves)
    _clear_backups.disabled = !global_GameManager.HasBackups()
    _confirm_clear.confirmed.connect(clear_settings)

    _player_name.text_changed.connect(_unsaved_changes)
    # connect all settings' relevant "-changed-" signals to "_unsaved_changes"

func _go_back() -> void:
    close.emit()
