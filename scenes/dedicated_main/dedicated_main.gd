extends Node

@export var _DefaultMenu : PackedScene = preload("res://scenes/menus/default_menu.tscn")

func _init() -> void:
    Engine.physics_ticks_per_second = Common._TICK_RATE
    global_MenuManager.LoadMenu(_DefaultMenu)

func _physics_process(delta: float) -> void:
    pass

func _process(delta: float) -> void:
    pass
