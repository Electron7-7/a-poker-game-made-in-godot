class_name GameManager extends Node2D

# Main Scene
const InitCasino : PackedScene = preload("res://main/casino.tscn")
# Main Node
static var TheCasino : Casino = null

# Game Settings
#static var AcesHigh : bool = true # Probably not needed to be a global variable

var _stop_requested  : bool = false
var _process_stopped : bool = true
var _physics_process_stopped : bool = true

func GetCurrentPlayer() -> GodotPlayer:
    var try_player : GodotPlayer = get_tree().get_nodes_in_group(GodotPlayer._group).get(0)
    if(try_player == null):
        try_player = GodotPlayer.new()
    return try_player

func IsGameRunning() -> bool:
    return (!_process_stopped || !_physics_process_stopped)

func StartNewGame() -> Error:
    if(IsGameRunning()):
        printerr("Tried to start a new game while the game is already running! The current game needs to be stopped before you can start a new one!")
        return ERR_ALREADY_IN_USE
    SaveData.Init()
    StartGame()
    return OK

func LoadGame(save_name : String) -> Error:
    if(IsGameRunning()):
        printerr("Tried to load a world while the game is already running in a world! The game needs to be stopped before you can start loading a new world!")
        return ERR_ALREADY_IN_USE
    var return_value : Error = global_CasinoManager.LoadSave(save_name)
    if(return_value == OK):
        StartGame()
    return return_value

func StartGame() -> void:
    if(IsGameRunning()):
        return
    _stop_requested = false
    _process_stopped = false
    _physics_process_stopped = false
    TheCasino = InitCasino.instantiate()
    add_child(TheCasino, true)
    move_child(TheCasino, 0)
    var new_player := GodotPlayer.new()
    TheCasino.add_child(new_player, true)

func StopGame() -> void:
    if(_stop_requested):
        return
    _stop_requested = IsGameRunning()
    TheCasino.queue_free()

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
