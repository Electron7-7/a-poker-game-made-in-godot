extends Control

signal close

@onready var _confirm_clear : ConfirmationDialog = $"%ConfirmClear"
@onready var _clear_notify  : AcceptDialog       = $"%ClearNotify"
@onready var _back_button : Button = $"%Back"
@onready var _save_button : Button = $"%Save"
@onready var _clear_settings : Button = $"%ClearSettings"
@onready var _clear_backups  : Button = $"%ClearBackups"
@onready var _player_name : LineEdit = $"%PlayerName"
@onready var _mouse_sensitivity_display : Label = $"%MouseSensitivityDisplay"
@onready var _mouse_sensitivity_slider : HSlider = $"%MouseSensitivitySlider"

func get_settings() -> Dictionary[String, Variant]:
    return \
    {
        SettingsManager.NAMES.PlayerName: _player_name.text,
        SettingsManager.NAMES.MouseSensitivity: _mouse_sensitivity_slider.value,
    }

func _confirm_clear_settings() -> void:
    _confirm_clear.visible = true

func clear_settings() -> void:
    global_SettingsManager.DANGEROUS_CleanSaveFile()
    _clear_notify.visible = true
    _clear_settings.disabled = true
    _clear_backups.disabled = !global_SettingsManager.HasBackups()
    global_SettingsManager.ClearSettings()
    global_SettingsManager.Save(false)
    load_settings()

func _clear_backup_saves() -> void:
    global_SettingsManager.DANGEROUS_CleanBackupFiles()
    _clear_backups.disabled = !global_SettingsManager.HasBackups()

func save_settings() -> void:
    global_SettingsManager.SaveSettings(get_settings())
    _clear_backups.disabled = !global_SettingsManager.HasBackups()
    _clear_settings.disabled = false
    _save_button.disabled = true

func load_settings() -> void:
    var loaded_settings : Dictionary[String, Variant] = global_SettingsManager.LoadSettings()
    # Get all settings here
    _player_name.text = loaded_settings.get(SettingsManager.NAMES.PlayerName)
    _mouse_sensitivity_slider.value = loaded_settings.get(SettingsManager.NAMES.MouseSensitivity)

func _unsaved_changes(_unused) -> void:
    _save_button.disabled = false

func _mouse_sensitivity_changed(new_value : float) -> void:
    _unsaved_changes(null)
    _mouse_sensitivity_display.text = String("%.2f" % new_value)

func _ready() -> void:
    _back_button.pressed.connect(_go_back)
    _save_button.pressed.connect(save_settings)
    _clear_settings.pressed.connect(_confirm_clear_settings)
    _clear_backups.pressed.connect(_clear_backup_saves)
    _clear_backups.disabled = !global_SettingsManager.HasBackups()
    _confirm_clear.confirmed.connect(clear_settings)

    # connect all settings' relevant "-changed-" signals to functions
    _player_name.text_changed.connect(_unsaved_changes)
    _mouse_sensitivity_slider.value_changed.connect(_mouse_sensitivity_changed)

func _go_back() -> void:
    close.emit()
