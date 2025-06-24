class_name MenuManager extends Control

static var main_menu : Control = preload("res://menus/main_menu.tscn").instantiate()
static var settings_menu : Control = preload("res://menus/settings_menu.tscn").instantiate()

func _init() -> void:
    main_menu.visible = false
    settings_menu.visible = false

func _ready() -> void:
    add_child(main_menu)
    add_child(settings_menu)

func _activate_menu(menu : Control) -> void:
    menu.visible = true

func _deactivate_menu(menu : Control) -> void:
    menu.visible = false

func _solo_menu(menu : Control) -> void:
    for child in get_children():
        _deactivate_menu(child as Control)
    _activate_menu(menu)

func InitSettings() -> void:
    settings_menu.load_settings()

func ShowMainMenu() -> void:
    _solo_menu(main_menu)

func SwitchMenus(from : Control, to: Control) -> void:
    _deactivate_menu(from)
    _activate_menu(to)
