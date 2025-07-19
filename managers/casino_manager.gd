class_name CasinoManager extends Node

enum SaveStatus
{
    OK           =  0, # Backups dir and save file exists
    INVALID      = -1, # No save file, no backups dir, but not empty
    ONLY_BACKUPS =  1, # No save file, but backups exist
    EMPTY_DIR    =  2, # No backups/backups dir and no save file
    NONEXISTANT  =  3, # Directory doesn't exist
}

const _save_file_extension := ".save"

const _saves_dir := "user://saves/"
const _backups_dir := "backups/"
const _save_data := "save_data"
const _save_backup := "backup_"

static var save_backup_limit : int = 5 # Probably make this higher / let user decide

var saves_dir : DirAccess = null

func Init() -> void:
    if(!DirAccess.open(_saves_dir)):
        DirAccess.make_dir_absolute(_saves_dir)
    saves_dir = DirAccess.open(_saves_dir)

func _ensure_backups_dir_exists(absolute_world_dir : String) -> Error:
    if(!DirAccess.dir_exists_absolute(absolute_world_dir)):
        push_error("Save file '%s' doesn't exist!" % absolute_world_dir)
        return ERR_CANT_CREATE
    DirAccess.make_dir_absolute(_ensure_dir_suffix(absolute_world_dir) + _backups_dir)
    return OK

func _clear_directory(absolute_path : String) -> void:
    for file in DirAccess.get_files_at(absolute_path):
        DirAccess.remove_absolute(_ensure_dir_suffix(absolute_path) + file)
    DirAccess.remove_absolute(absolute_path)

func DeleteSave(save_name : String) -> void:
    var save_dir : String = _saves_dir + _ensure_dir_suffix(save_name)
    for dir in DirAccess.get_directories_at(save_dir):
        _clear_directory(save_dir + dir)
    _clear_directory(save_dir)

func CreateNewSave(save_name : String) -> void:
    if(saves_dir.dir_exists(save_name)):
        push_warning("Savegame '%s' already exists and will be overwritten!" % save_name)
        DeleteSave(save_name)
    saves_dir.make_dir(save_name)
    saves_dir.make_dir(_ensure_dir_suffix(save_name) + _backups_dir)
    var save_file := FileAccess.open(_saves_dir + _ensure_dir_suffix(save_name) + _save_file(), FileAccess.WRITE)
    save_file.close()

func SaveGame(save_name : String) -> void:
    var save_status : SaveStatus = GetSaveStatus(save_name)
    match(save_status):
        SaveStatus.ONLY_BACKUPS:
            if(SetLastBackupAsSave(save_name) != OK):
                CreateNewSave(save_name)
        SaveStatus.NONEXISTANT || SaveStatus.EMPTY_DIR || SaveStatus.INVALID:
            CreateNewSave(save_name)
    #var save_dir : String = _saves_dir + _ensure_dir_suffix(save_name)
    #var save_file : String = save_dir + _save_file()
    #var temp_extension : String = ".temp"
    #var temp_save_file := FileAccess.open(save_file + temp_extension, FileAccess.WRITE)

    #for node in save_nodes:
        #if(node.scene_file_path.is_empty()):
            #printerr("WorldManager::SaveWorld - Persistent node '%s' is not an instanced scene and will be skipped." % node.name)
            #continue
        #if(!node.has_method("save")):
            #printerr("WorldManager::SaveWorld - Persistent node '%s' is missing a 'save()' function and will be skipped." % node.name)
            #continue

        #var node_data = node.call("save")
        #var json_string = JSON.stringify(node_data)
        #temp_save_file.store_line(json_string)
    #temp_save_file.close()

    #if(FileAccess.file_exists(save_file_absolute)):
        #_ensure_backups_dir_exists(world_dir)
        #DirAccess.rename_absolute(save_file_absolute, world_dir + _backups_dir + _world_backup_name())
    #DirAccess.rename_absolute(save_file_absolute + temp_extension, save_file_absolute)

func LoadSave(save_name : String) -> Error:
    var save_status : SaveStatus = GetSaveStatus(save_name)
    match(save_name):
        SaveStatus.ONLY_BACKUPS:
            print_debug("Savegame %s has no save but does have at least one backup; setting the last backup as the new save file before continuing." % save_name)
            if(SetLastBackupAsSave(save_name) != OK):
                CreateNewSave(save_name)
        SaveStatus.OK:
            print_debug("Savegame %s will be loaded" % save_name)
        _:
            printerr("Savegame '%s' is unable to be loaded! SaveStatus error code: '%d'" % [save_name,save_status])
            return ERR_CANT_ACQUIRE_RESOURCE

    #var save_nodes : Array[Node] = get_tree().get_nodes_in_group("Persist")
    #for node in save_nodes:
        #node.queue_free()
    #var save_file := FileAccess.open(_saves_dir + _ensure_dir_suffix(save_name) + _save_file(), FileAccess.READ)
    #while(save_file.get_position() < save_file.get_length()):
        #var json_string : String = save_file.get_line()
        #var json := JSON.new()
        #var parse_result = json.parse(json_string)
        #if(parse_result != OK):
            #printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
            #continue
        #var node_data : Variant = json.data
        #var new_object : Node = load(node_data["filename"]).instantiate()
        ## FIXME: This needs to be better suited to the project's purposes
        ## (Code ripped from - "https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html")
        #get_node(node_data["parent"]).add_child(new_object)
        #new_object.position = Vector3(node_data["pos_x"], node_data["pos_y"], node_data["pos_z"])
        #for key in node_data.keys():
            #if(key == "filename" || "parent" || "pos_x" || "pos_y" || "pos_z"):
                #continue
            #new_object.set(key, node_data.get(key))
    return OK

func GetSaveStatus(save_name : String) -> SaveStatus:
    if(!saves_dir.dir_exists(save_name)):
        return SaveStatus.NONEXISTANT
    var save_dir : String = _saves_dir + _ensure_dir_suffix(save_name)
    if(DirAccess.get_files_at(save_dir).size() <= 0 && DirAccess.get_directories_at(save_dir).size() <= 0):
        return SaveStatus.EMPTY_DIR
    if(!DirAccess.open(save_dir).file_exists(_save_file())):
        if(DirAccess.open(save_dir).dir_exists(_backups_dir) && DirAccess.get_files_at(save_dir + _backups_dir).size() > 0):
            return SaveStatus.ONLY_BACKUPS
        return SaveStatus.INVALID
    return SaveStatus.OK

func SetLastBackupAsSave(save_name : String) -> Error:
    if(GetSaveStatus(save_name) == SaveStatus.INVALID || SaveStatus.EMPTY_DIR || SaveStatus.NONEXISTANT):
        push_error("Cannot load backup save for savegame '%s'!" % save_name)
        return ERR_FILE_NOT_FOUND
    var save_dir := DirAccess.open(_saves_dir + save_name)
    var all_backups : PackedStringArray = DirAccess.get_files_at(_saves_dir + _ensure_dir_suffix(save_name) + _backups_dir)
    save_dir.copy(_backups_dir + all_backups.get(all_backups.size() - 1), _save_file())
    return OK

#------------------------------------------------------------------
# These functions help keep the use of file names mostly de-tangled
#------------------------------------------------------------------
func _ensure_dir_suffix(save : String) -> String:
    if(!save.ends_with("/")):
        return(save + "/")
    return save

func _save_file() -> String:
    return _save_data + _save_file_extension

func _backup_file() -> String:
    return _save_backup + Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":","-") + _save_file_extension

#-----------------------------------------------------
# These functions are mainly used by the settings menu
#-----------------------------------------------------
func CleanBadSaves() -> void:
    for save in saves_dir.get_directories():
        var status : SaveStatus = GetSaveStatus(save)
        match status:
            SaveStatus.OK:
                continue
            SaveStatus.ONLY_BACKUPS:
                print_debug("%s has no save file, but does have backups and will not be cleaned." % save)
                continue
            SaveStatus.NONEXISTANT:
                print_debug("%s does not exist!" % save)
                continue
            SaveStatus.EMPTY_DIR:
                print_debug("%s is empty and will be cleaned." % save)
            SaveStatus.INVALID:
                print_debug("%s is invalid and will be cleaned." % save)
        DeleteSave(save)

func HasSaveFiles() -> bool:
    return(saves_dir.get_directories().size() > 0)

func GetSaveNames() -> PackedStringArray:
    return(saves_dir.get_directories())
