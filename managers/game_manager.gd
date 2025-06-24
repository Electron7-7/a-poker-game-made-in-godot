class_name GameManager extends Node

static var _is_game_running   : bool = false
static var _is_stop_requested : bool = false
static var _save_file         := ConfigFile.new()

const _save_file_main   := "user://save_data.ini"
const _save_file_backup := "user://save_data_backup.ini"
const _try_save_limit   := 10

func _notification(what: int) -> void:
    if(what == Object.NOTIFICATION_PREDELETE): # Pseudo-Destructor
        var i : int = 0
        var save_ret : Error = FAILED
        while(save_ret != OK && i < _try_save_limit):
            save_ret = SaveAll()
            i += 1
        if(save_ret != OK):
            printerr("Something went wrong while writing to the save file! There should be a backup save file that you can use to manually fix/update the main save file.")

func DANGEROUS_ClearAllSaveData() -> void:
    _save_file.save(_save_file_backup)
    _save_file = ConfigFile.new()
    _save_file.save(_save_file_main)

func InitSaveData() -> void:
    if(_save_file.load(_save_file_main) != OK): # Try to load the save file
        if(_save_file.load(_save_file_backup) != OK): # Try to load the backup file
            _save_file.save(_save_file_main) # Create a fresh save file

func SaveAll() -> Error:
    _save_file.save(_save_file_backup)
    return _save_file.save(_save_file_main)

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

func Load(section : String, key : String) -> SafeReturn:
    if(!_save_file.has_section_key(section, key)):
        return SafeReturn.new(ERR_DOES_NOT_EXIST, null)
    return SafeReturn.new(OK, _save_file.get_value(section, key))

func LoadSection(section : String) -> SafeReturn:
    if(!_save_file.has_section(section)):
        return SafeReturn.new(ERR_DOES_NOT_EXIST, null)
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
