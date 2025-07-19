extends Control

signal close

@onready var _confirm_clear : ConfirmationDialog = $"%ConfirmClear"
@onready var _clear_notify  : AcceptDialog       = $"%ClearNotify"
@onready var _back_button : Button = $"%Back"
@onready var _save_button : Button = $"%Save"
@onready var _undo_button : Button = $"%Undo"
@onready var _clear_settings : Button = $"%ClearSettings"
@onready var _clear_backups  : Button = $"%ClearBackups"
@onready var _player_name : LineEdit = $"%PlayerName"
@onready var _mouse_sensitivity_display : LineEdit = $"%MouseSensitivityDisplay"
@onready var _mouse_sensitivity_slider : HSlider = $"%MouseSensitivitySlider"
@onready var _mouse_sensitivity_multiplier : LineEdit = $"%SensitivityMultiplier"
@onready var _fov_display : LineEdit = $"%FOVDisplay"
@onready var _fov_slider : HSlider = $"%FOV"

func get_settings() -> Dictionary[String, Variant]:
    return \
    {
        SettingsManager.NAMES.PlayerName: _player_name.text,
        SettingsManager.NAMES.MouseSensitivity: _mouse_sensitivity_slider.value,
        SettingsManager.NAMES.MouseSensitivityScale: _valid_sensitivity_multiplier(),
        SettingsManager.NAMES.FOV: _fov_slider.value
    }

func _valid_sensitivity_multiplier() -> float:
    if(_mouse_sensitivity_multiplier.text.is_valid_float()):
        return _mouse_sensitivity_multiplier.text.to_float()
    return SettingsManager.DEFAULTS.MouseSensitivityScale

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
    _undo_button.disabled = true

func undo_changes() -> void:
    load_settings()
    _save_button.disabled = true
    _undo_button.disabled = true

func load_settings() -> void:
    var loaded_settings : Dictionary[String, Variant] = global_SettingsManager.LoadSettings()
    # Get all settings here
    _player_name.text = loaded_settings.get(SettingsManager.NAMES.PlayerName)
    _mouse_sensitivity_slider.value = loaded_settings.get(SettingsManager.NAMES.MouseSensitivity)
    _mouse_sensitivity_multiplier.text = String("%.2f" % loaded_settings.get(SettingsManager.NAMES.MouseSensitivityScale))
    _fov_slider.value = loaded_settings.get(SettingsManager.NAMES.FOV)

func _unsaved_changes(_unused = null) -> void:
    _save_button.disabled = false
    _undo_button.disabled = false

func _mouse_sensitivity_changed(new_value : float) -> void:
    _unsaved_changes()
    _mouse_sensitivity_display.text = String("%.2f" % new_value)

func _mouse_sensitivity_display_changed(new_value : String) -> void:
    if(!new_value.is_valid_float()):
        _mouse_sensitivity_display.text = String("%.2f" % _mouse_sensitivity_slider.value)
        return
    _mouse_sensitivity_slider.value = new_value.to_float()
    _unsaved_changes()

func _fov_changed(new_value : int) -> void:
    _unsaved_changes()
    _fov_display.text = String("%d" % new_value)

func _fov_display_changed(new_value : String) -> void:
    if(!new_value.is_valid_float()):
        _fov_display.text = String("%d" % _fov_slider.value)
        return
    _fov_slider.value = new_value.to_float()
    _unsaved_changes()

func _input(event: InputEvent) -> void:
    if(event.is_action("ui_cancel") && visible):
        _go_back()

func Init() -> void:
    load_settings()
    _save_button.disabled = true
    _undo_button.disabled = true

func _ready() -> void:
    # Settings signals
    # connect all settings' relevant "-changed-" signals to functions
    _player_name.text_changed.connect(_unsaved_changes)
    _mouse_sensitivity_slider.value_changed.connect(_mouse_sensitivity_changed)
    _mouse_sensitivity_display.text_submitted.connect(_mouse_sensitivity_display_changed)
    _mouse_sensitivity_multiplier.text_changed.connect(_unsaved_changes)
    _fov_slider.value_changed.connect(_fov_changed)
    _fov_display.text_submitted.connect(_fov_display_changed)

    # other signal connections that aren't from settings
    _back_button.pressed.connect(_go_back)
    _save_button.pressed.connect(save_settings)
    _undo_button.pressed.connect(undo_changes)
    _clear_settings.pressed.connect(_confirm_clear_settings)
    _clear_backups.pressed.connect(_clear_backup_saves)
    _clear_backups.disabled = !global_SettingsManager.HasBackups()
    _confirm_clear.confirmed.connect(clear_settings)

func _go_back() -> void:
    if(!_save_button.disabled):
        undo_changes()
    close.emit()
