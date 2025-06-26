class_name WorldManager extends Node

enum WorldStatus
{
    OK = 0,
    ERR_NOT_A_WORLD = 1,
    ERR_EMPTY = 2,
    ERR_NO_SAVE = 3,
    ERR_NO_SAVE_AND_NO_BACKUPS = 4
}

const _save_file_extension := ".save"

const _worlds_dir := "user://worlds/"
const _backups_dir := "backups/"
const _world_save := "world_save"
const _world_backup := "world_backup_"

static var world_backup_limit : int = 5 # Probably make this higher / let user decide

var worlds_dir : DirAccess = null

func Init() -> void:
    if(!DirAccess.open(_worlds_dir)):
        DirAccess.make_dir_absolute(_worlds_dir)
    worlds_dir = DirAccess.open(_worlds_dir)

func _ensure_backups_dir_exists(absolute_world_dir : String) -> void:
    if(!DirAccess.dir_exists_absolute(absolute_world_dir)):
        printerr("World at '%s' doesn't exist!" % absolute_world_dir)
        return
    DirAccess.make_dir_absolute(_ensure_dir_suffix(absolute_world_dir) + _backups_dir)

func CreateNewWorld(world_name : String) -> Error:
    if(worlds_dir.dir_exists(world_name)):
        printerr("WorldManager::CreateNewWorld - World '%s' already exists!" % world_name)
        return ERR_ALREADY_EXISTS
    worlds_dir.make_dir(world_name)
    worlds_dir.make_dir(_ensure_dir_suffix(world_name) + _backups_dir)
    SaveWorld(world_name)
    return OK

func SaveWorld(world_name : String) -> void:
    var save_nodes : Array[Node] = get_tree().get_nodes_in_group("Persist")
    var world_status : WorldStatus = GetWorldStatus(world_name)
    match(world_status):
        WorldStatus.ERR_NOT_A_WORLD:
            print("World %s doesn't exist, so a new world directory will be made for it" % world_status)
            CreateNewWorld(world_name)

    var world_dir : String = _worlds_dir + _ensure_dir_suffix(world_name)
    var save_file_absolute : String = world_dir + _world_save_name()
    var temp_extension : String = ".temp"
    var temp_save_file := FileAccess.open(save_file_absolute + temp_extension, FileAccess.WRITE)

    for node in save_nodes:
        if(node.scene_file_path.is_empty()):
            printerr("WorldManager::SaveWorld - Persistent node '%s' is not an instanced scene and will be skipped." % node.name)
            continue
        if(!node.has_method("save")):
            printerr("WorldManager::SaveWorld - Persistent node '%s' is missing a 'save()' function and will be skipped." % node.name)
            continue

        var node_data = node.call("save")
        var json_string = JSON.stringify(node_data)
        temp_save_file.store_line(json_string)
    temp_save_file.close()

    if(FileAccess.file_exists(save_file_absolute)):
        _ensure_backups_dir_exists(world_dir)
        DirAccess.rename_absolute(save_file_absolute, world_dir + _backups_dir + _world_backup_name())
    DirAccess.rename_absolute(save_file_absolute + temp_extension, save_file_absolute)

func LoadWorld(world_name : String) -> Error:
    var world_status : WorldStatus = GetWorldStatus(world_name)
    match(world_status):
        WorldStatus.ERR_NO_SAVE:
            print_debug("World %s has no save but does have at least one backup; setting the last backup as the world save before continuing." % world_name)
            SetLastBackupAsWorldSave(world_name)
        WorldStatus.OK:
            print_debug("World %s will be loaded" % world_name)
        _:
            printerr("World '%s' is unable to be loaded! WorldStatus error code: '%d'" % [world_name,world_status])
            return ERR_CANT_ACQUIRE_RESOURCE

    var save_nodes : Array[Node] = get_tree().get_nodes_in_group("Persist")
    for node in save_nodes:
        node.queue_free()

    var save_file := FileAccess.open(_worlds_dir + _ensure_dir_suffix(world_name) + _world_save_name(), FileAccess.READ)
    while(save_file.get_position() < save_file.get_length()):
        var json_string : String = save_file.get_line()
        var json := JSON.new()

        var parse_result = json.parse(json_string)
        if(parse_result != OK):
            printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
            continue

        var node_data : Variant = json.data
        var new_object : Node = load(node_data["filename"]).instantiate()
        # FIXME: This needs to be better suited to the project's purposes
        # (Code ripped from - "https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html")
        get_node(node_data["parent"]).add_child(new_object)
        new_object.position = Vector3(node_data["pos_x"], node_data["pos_y"], node_data["pos_z"])
        for key in node_data.keys():
            if(key == "filename" || "parent" || "pos_x" || "pos_y" || "pos_z"):
                continue
            new_object.set(key, node_data.get(key))
    return OK

func GetWorldStatus(relative_world_directory : String) -> WorldStatus:
    if(!worlds_dir.dir_exists(relative_world_directory)):
        return WorldStatus.ERR_NOT_A_WORLD
    var requested_world_dir : String = _worlds_dir + _ensure_dir_suffix(relative_world_directory)
    if(DirAccess.get_files_at(requested_world_dir).size() <= 0):
        return WorldStatus.ERR_EMPTY
    if(!DirAccess.open(requested_world_dir).file_exists(_world_save_name())):
        if(!DirAccess.open(requested_world_dir).dir_exists(_backups_dir) || DirAccess.open(requested_world_dir + _backups_dir).get_files().size() <= 0):
            return WorldStatus.ERR_NO_SAVE_AND_NO_BACKUPS
        return WorldStatus.ERR_NO_SAVE
    return WorldStatus.OK

func SetLastBackupAsWorldSave(relative_world_directory : String) -> void:
    _ensure_backups_dir_exists(_worlds_dir + relative_world_directory)
    var world_dir := DirAccess.open(_worlds_dir + relative_world_directory)
    var all_backups : PackedStringArray = DirAccess.get_files_at(_worlds_dir + _ensure_dir_suffix(relative_world_directory) + _backups_dir)
    world_dir.copy(_backups_dir + all_backups.get(all_backups.size() - 1), _world_save_name())

#------------------------------------------------------------------
# These functions help keep the use of file names mostly de-tangled
#------------------------------------------------------------------
func _ensure_dir_suffix(world : String) -> String:
    if(!world.ends_with("/")):
        return(world + "/")
    return world

func _world_save_name() -> String:
    return _world_save + _save_file_extension

func _world_backup_name() -> String:
    return _world_backup + Time.get_date_string_from_system() + "_" + Time.get_time_string_from_system().replace(":","-") + _save_file_extension

#-----------------------------------------------------
# These functions are mainly used by the settings menu
#-----------------------------------------------------
func CheckAndCleanWorlds() -> void:
    for world in worlds_dir.get_directories():
        var status : WorldStatus = GetWorldStatus(world)
        match status:
            WorldStatus.OK:
                print_debug("%s is a valid world and will not be cleaned." % world)
                continue
            WorldStatus.ERR_NO_SAVE:
                print_debug("%s has no save file, but does have backups and will not be cleaned.")
                continue
            WorldStatus.ERR_NOT_A_WORLD:
                print_debug("%s is not a world and will be cleaned." % world)
            WorldStatus.ERR_EMPTY:
                print_debug("%s is empty and will be cleaned." % world)
            WorldStatus.ERR_NO_SAVE_AND_NO_BACKUPS:
                print_debug("%s has no saves or backups and will be cleaned." % world)
        CleanWorld(world)

func _remove_all_files_from_directory(directory : DirAccess) -> void:
    for file in directory.get_files():
        if(directory.remove(file) != OK):
            printerr("WorldManager::_remove_all_files_from_directory - Failed to remove the file: %s!" % file)

func CleanWorld(relative_world_dir : String) -> void:
    var world := DirAccess.open(_worlds_dir + relative_world_dir)
    _remove_all_files_from_directory(world)
    if(world.get_directories().size() > 0):
        for dir in world.get_directories():
            _remove_all_files_from_directory(DirAccess.open(_worlds_dir + _ensure_dir_suffix(relative_world_dir) + dir))
            world.remove(dir)
    if(worlds_dir.remove(relative_world_dir) != OK):
        printerr("WorldManager::CleanWorld - Failed to remove the world directory: %s!" % relative_world_dir)

func HasWorlds() -> bool:
    return(worlds_dir.get_directories().size() > 0)

func GetWorldNames() -> PackedStringArray:
    return(worlds_dir.get_directories())
