class_name MenuManager extends Control

static var _main_menu : Control = preload("res://menus/main_menu.tscn").instantiate()
static var settings_menu : Control = preload("res://menus/settings_menu.tscn").instantiate()

func _init() -> void:
    _main_menu.visible = false
    call_deferred("add_child", _main_menu, true)

func _activate_menu(menu : Control) -> void:
    menu.visible = true

func _deactivate_menu(menu : Control) -> void:
    menu.visible = false

func _solo_menu(menu : Control) -> void:
    for child in get_children():
        _deactivate_menu(child as Control)
    _activate_menu(menu)

func ShowMainMenu() -> void:
    _solo_menu(_main_menu)
