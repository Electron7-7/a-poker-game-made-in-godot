class_name MenuManager extends Control

static var main_menu : Control = preload("res://menus/main_menu.tscn").instantiate()
static var settings_menu : Control = preload("res://menus/settings_menu.tscn").instantiate()
static var server_menu : Control = preload("res://menus/server_menu.tscn").instantiate()

static var _pause_menu_last_visible : bool = true

func TogglePauseMenu() -> void:
    if(main_menu.visible == _pause_menu_last_visible):
        return
    _pause_menu_last_visible = main_menu.visible
    main_menu.visible = !main_menu.visible

func ActivateMenu(menu : Control) -> void:
    menu.visible = true

func DeactivateMenu(menu : Control) -> void:
    menu.visible = false

func Init() -> void:
    main_menu.visible = true
    settings_menu.visible = false
    server_menu.visible = false
    add_child(main_menu)
    add_child(settings_menu)
    add_child(server_menu)
    main_menu.Init()
    settings_menu.load_settings()

func CloseAllMenus() -> void:
    _pause_menu_last_visible = true;
    DeactivateMenu(main_menu)
    DeactivateMenu(settings_menu)
    DeactivateMenu(server_menu)

func ReturnToMainMenu() -> void:
    CloseAllMenus()
    ActivateMenu(main_menu)

func SwitchMenus(to: Control, from : Control = null) -> void:
    ActivateMenu(to)
    if(from == null):
        return
    DeactivateMenu(from)

func _input(event: InputEvent) -> void:
    if(event.is_action_pressed("ui_cancel") && global_GameManager.IsGameRunning()):
        TogglePauseMenu()
