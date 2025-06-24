class_name MenuManager extends Control

static var main_menu : Control = preload("res://menus/main_menu.tscn").instantiate()
static var settings_menu : Control = preload("res://menus/settings_menu.tscn").instantiate()
static var server_menu : Control = preload("res://menus/server_menu.tscn").instantiate()

func _activate_menu(menu : Control) -> void:
    if(menu == main_menu):
        menu.set_pause_menu(global_GameManager.IsGameRunning())
    menu.visible = true

func _deactivate_menu(menu : Control) -> void:
    menu.visible = false

func _solo_menu(menu : Control) -> void:
    for child in get_children():
        _deactivate_menu(child as Control)
    _activate_menu(menu)

func Init() -> void:
    main_menu.visible = false
    settings_menu.visible = false
    server_menu.visible = false
    add_child(main_menu)
    add_child(settings_menu)
    add_child(server_menu)
    main_menu.Init()
    settings_menu.load_settings()
    _solo_menu(main_menu)

func SwitchMenus(to: Control, from : Control = null) -> void:
    _activate_menu(to)
    if(from == null):
        return
    _deactivate_menu(from)
