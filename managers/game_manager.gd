class_name GameManager extends Node

static var _is_game_running   : bool = false
static var _is_stop_requested : bool = false
static var _save_backup_limit : int = 5 # Probably make this higher / let user decide

static var _save_file   := ConfigFile.new()
const _save_location    := "user://save_files/"
const _backup_location  := _save_location + "backups/"
const _save_file_main   := "save_data"
const _save_file_backup := "save_data_backup_"
const _save_extension   := ".ini"

static var _backup_saves : PackedStringArray = DirAccess.open(_backup_location).get_files()

func _save_name_main() -> String:
    return _save_location + _save_file_main + _save_extension

func _save_name_backup() -> String:
    if(_backup_saves.size() >= _save_backup_limit):
        print_debug("Save backup limit reached; removing backup file at: %s" % _backup_saves.get(0))
        if(DirAccess.open(_save_location).remove(_backup_saves.get(0))):
            _backup_saves.remove_at(0)
    var new_backup_name : String = _backup_location + _save_file_backup + "_" + Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":","-") + _save_extension
    _backup_saves.append(new_backup_name)
    return new_backup_name

func _notification(what: int) -> void:
    if(what == Object.NOTIFICATION_PREDELETE): # Pseudo-Destructor
        if(_save_file.save(_save_name_main()) != OK):
            printerr("Something went wrong while writing to the save file! There should be a backup save file that you can use to manually fix/update the main save file.")

func HasBackups() -> bool:
    return DirAccess.open(_backup_location).get_files().size() > 0

func DANGEROUS_ClearBackupSaveData() -> void:
    for backup in _backup_saves:
        DirAccess.open(_backup_location).remove(backup)
    _backup_saves.clear()

func DANGEROUS_ClearAllSaveData() -> void:
    _save_file.save(_save_name_backup()) # Make a backup, first
    _save_file = ConfigFile.new() # Clear save object
    _save_file.save(_save_name_main()) # Clear save file

func InitSaveData() -> void:
    if(!DirAccess.open(_save_location)):
        DirAccess.make_dir_absolute(_save_location)

    if(!DirAccess.open(_backup_location)):
        DirAccess.make_dir_absolute(_backup_location)

    if(_save_file.load(_save_name_main()) != OK): # Try to load the save file
        if(_save_file.load(_save_file_backup) != OK): # Try to load the backup file
            _save_file.save(_save_name_main()) # Instantiate new empty save file
            return
        _save_file.load(_save_file_backup) # Load backup as new save file

func SaveToFile() -> void:
    _save_file.save(_save_name_backup())
    _save_file.save(_save_name_main())

func LoadAll(section: String) -> SafeReturn:
    if(!_save_file.has_section(section)):
        return SafeReturn.new(ERR_DOES_NOT_EXIST, null)
    var keys_return : Dictionary[String, Variant] = {}
    var keys : PackedStringArray = _save_file.get_section_keys(section)
    for key in keys:
        keys_return[key] = _save_file.get_value(section, key)
    return SafeReturn.new(OK, keys_return)

func Save(section : String, key : String, data : Variant) -> void:
    _save_file.set_value(section, key, data)

func SaveSection(section : String, data : Dictionary[String, Variant]) -> void:
    for key in data:
        Save(section, key, data.get(key))

func Load(section : String, key : String, default_value : Variant) -> Variant:
    if(_save_file.has_section_key(section, key)):
        return _save_file.get_value(section, key)
    if(!_save_file.has_section(section)):
        printerr("GameManager::Load - the requested section doesn't exist! This function will return the default value for the requested key, and save it in the requested section. This will create a section in the save file that'll be empty except for this one key. Keep this in mind if any issues occur related to save data.")
        Save(section, key, default_value)
    # FIXME: Decide whether or not to also save the default value if the section exists but the key doesn't
    return default_value

func LoadSection(section : String, default_values : Dictionary[String, Variant]) -> SafeReturn:
    if(!_save_file.has_section(section)):
        SaveSection(section, default_values)
    var keys : PackedStringArray = _save_file.get_section_keys(section)
    var data : Dictionary[String, Variant] = {}
    for key in keys:
        data[key] = _save_file.get_value(section, key)
    return SafeReturn.new(OK, data)

static func Start() -> void:
    if(_is_game_running):
        return

static func Stop() -> void:
    if(_is_stop_requested):
        return

func _process(delta: float) -> void:
    if(!_is_game_running):
        return

func _physics_process(delta: float) -> void:
    if(!_is_game_running):
        return
