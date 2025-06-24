class_name WorldManager extends Node

const _save_file_extension := ".ini"

const _worlds_saves_dir := "user://worlds/"
const _worlds_backups_dir := "backups/"
const _world_save_files_name := "world_save"
const _world_backup_files_name := "world_backup_"

static var _world_backup_limit : int = 5 # Probably make this higher / let user decide
static var _current_world_save_dir : String = ""
static var _current_world_save_file := ConfigFile.new()
static var worlds_saves_dir : DirAccess = null

func Init() -> void:
    if(!DirAccess.open(_worlds_saves_dir)):
        DirAccess.make_dir_absolute(_worlds_saves_dir)
    worlds_saves_dir = DirAccess.open(_worlds_saves_dir)

func HasWorlds() -> bool:
    return(worlds_saves_dir.get_directories().size() > 0)

func GetWorldNames() -> PackedStringArray:
    return(worlds_saves_dir.get_directories())
