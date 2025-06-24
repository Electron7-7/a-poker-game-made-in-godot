class_name SettingsManager extends Node

const _save_file_extension := ".ini"

const _settings_dir := "user://settings/"
const _settings_backups_dir := "backups/"
const _settings_save_file_name := "settings"
const _settings_backup_files_name := "settings_backup_"

static var settings_backup_limit : int = 5 # Probably make this higher / let user decide
static var settings_save_file := ConfigFile.new()
static var settings_save_dir : DirAccess = null
static var settings_backups_dir : DirAccess = null

func _notification(what: int) -> void:
    if(what == Object.NOTIFICATION_PREDELETE): # Pseudo-Destructor
        if(settings_save_file.save(_settings_file_name()) != OK):
            printerr("Something went wrong while writing to the save file! There should be a backup save file that you can use to manually fix/update the main save file.")

func _settings_file_name() -> String:
    return _settings_dir + _settings_save_file_name + _save_file_extension

func _settings_backup_name() -> String:
    return _settings_dir + _settings_backups_dir + _settings_backup_files_name + Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":","-") + _save_file_extension

func Init() -> void:
    if(DirAccess.open(_settings_dir) == null):
        DirAccess.make_dir_absolute(_settings_dir)
    if(!DirAccess.open(_settings_dir).dir_exists(_settings_backups_dir)):
        DirAccess.open(_settings_dir).make_dir(_settings_backups_dir)

    settings_save_dir = DirAccess.open(_settings_dir)
    settings_backups_dir = DirAccess.open(_settings_dir + _settings_backups_dir)
    Load()

func SaveBackup() -> void:
    var backups : PackedStringArray = settings_backups_dir.get_files()
    if(backups.size() >= settings_backup_limit):
        print_debug("Save backup limit reached; removing backup file at: %s" % backups.get(0))
        settings_backups_dir.remove(backups.get(0))
    settings_save_file.save(_settings_backup_name())

func Save(save_backup : bool = true) -> Error:
    if(save_backup):
        SaveBackup()
    return settings_save_file.save(_settings_file_name())

func Load() -> void:
    if(settings_save_file.load(_settings_file_name()) != OK): # Try to load the save file
        var backup_files : PackedStringArray = settings_backups_dir.get_files()
        if(settings_save_file.load(settings_backups_dir.get(settings_backups_dir.size() - 1)) != OK): # Try to load the latest backup file
            settings_save_file.save(_settings_file_name()) # Instantiate new empty save file
            return

func HasBackups() -> bool:
    return(settings_backups_dir.get_files().size() > 0)

func SetValue(section : String, key : String, value : Variant) -> void:
    settings_save_file.set_value(section, key, value)

func SetSection(section : String, data : Dictionary[String, Variant]) -> void:
    for key in data:
        SetValue(section, key, data.get(key))

func GetValue(section : String, key : String, default : Variant) -> Variant:
    return settings_save_file.get_value(section, key, default)

func GetSection(section : String, defaults : Dictionary[String, Variant]) -> Dictionary[String, Variant]:
    var return_data : Dictionary[String, Variant] = {}
    for key in defaults:
        return_data[key] = GetValue(section, key, defaults.get(key))
    return return_data

func DANGEROUS_CleanSaveFile() -> Error:
    print_debug("Making one more settings backup before cleaning!")
    SaveBackup()
    print_debug("Cleaning the settings save file!")
    settings_save_file = ConfigFile.new()
    return settings_save_file.save(_settings_file_name())

func DANGEROUS_CleanBackupFiles() -> void:
    print_debug("Cleaning the settings backup save files!")
    for file in settings_backups_dir.get_files():
        print("Cleaning: %s" % file)
        if(settings_backups_dir.remove(file) != OK):
            printerr("SettingsManager::DANGEROUS_CleanBackupFiles - failed to remove the file: %s" % file)
