class_name GameManager extends Node

static var _is_game_running   : bool = false
static var _is_stop_requested : bool = false

func IsGameRunning() -> bool:
    return _is_game_running

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
