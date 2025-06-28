class_name GameManager extends Node3D

const MainWorld : PackedScene = preload("res://main/world.tscn")
const Player : PackedScene = preload("res://things/godot_player/godot_player.tscn")

static var world : World = null

var _stop_requested  : bool = false
var _process_stopped : bool = true
var _physics_process_stopped : bool = true

func GetCurrentPlayer() -> GodotPlayer:
    var try_player : GodotPlayer = get_tree().get_nodes_in_group(GodotPlayer.PlayerGroup).get(0)
    if(try_player == null):
        try_player = GodotPlayer.new()
    return try_player

func IsGameRunning() -> bool:
    return (!_process_stopped || !_physics_process_stopped)

func StartNewGame(new_world_name : String) -> Error:
    if(IsGameRunning()):
        printerr("Tried to start a new game while the game is already running! The current game needs to be stopped before you can start a new one!")
        return ERR_ALREADY_IN_USE
    var return_value : Error = global_WorldManager.CreateNewWorld(new_world_name)
    if(return_value == OK):
        global_GameManager._start()
    return return_value

func LoadGame(world_save_name : String) -> Error:
    if(IsGameRunning()):
        printerr("Tried to load a world while the game is already running in a world! The game needs to be stopped before you can start loading a new world!")
        return ERR_ALREADY_IN_USE
    var return_value : Error = global_WorldManager.LoadWorld(world_save_name)
    if(return_value == OK):
        global_GameManager._start()
    return return_value

func _start() -> void:
    if(IsGameRunning()):
        return
    _stop_requested = false
    _process_stopped = false
    _physics_process_stopped = false
    world = MainWorld.instantiate()
    add_child(world, true)
    var new_player : GodotPlayer = Player.instantiate()
    world.add_child(new_player, true)
    new_player.position = get_tree().get_nodes_in_group(PlayerSpawn.GroupName).get(0).position

func StopGame() -> void:
    if(_stop_requested):
        return
    _stop_requested = IsGameRunning()
    world.queue_free()

func _check_if_game_stopped() -> void:
    if(!_process_stopped || !_physics_process_stopped):
        return
    global_MenuManager.ReturnToMainMenu()

func _graceful_stop() -> void:
    # stop logic
    _process_stopped = true
    _check_if_game_stopped()

func _graceful_physics_stop() -> void:
    # stop logic
    _physics_process_stopped = true
    _check_if_game_stopped()

func _process(_delta: float) -> void:
    if(!IsGameRunning()):
        return
    if(_stop_requested):
        _graceful_stop()
        return

func _physics_process(_delta: float) -> void:
    if(!IsGameRunning()):
        return
    if(_stop_requested):
        _graceful_physics_stop()
        return
