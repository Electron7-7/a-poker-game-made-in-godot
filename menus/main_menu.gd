extends Control

@onready var _main_menu  : VBoxContainer = $"%MainMenu"
@onready var _pause_menu : VBoxContainer = $"%PauseMenu"

@onready var _world_name      : LineEdit = $"%WorldName"
@onready var _saves           : ScrollContainer = $"%Saves"
@onready var _save_games      : VBoxContainer = $"%SaveGames"
@onready var _confirm_quit    : ConfirmationDialog = $"%ConfirmQuit"
@onready var _new_game_menu   : PanelContainer = $"%NewGameMenu"
@onready var _settings_button : Button = $"%Settings"
@onready var _pause_settings  : Button = $"%PauseSettings"
@onready var _back_to_game    : Button = $"%Resume"
@onready var _exit_button     : Button = $"%Exit"
@onready var _quit_button     : Button = $"%Quit"
@onready var _new_button      : Button = $"%New"
@onready var _continue_button : Button = $"%Continue"
@onready var _template_world  : Button = $"%_WorldTemplate"
@onready var _start_new_game  : Button = $"%StartNewGame"
@onready var _cancel_new_game : Button = $"%CancelNewGame"

func Init() -> void:
    _exit_button.pressed.connect(try_exit)
    _settings_button.pressed.connect(toggle_settings.bind(true))
    _pause_settings.pressed.connect(toggle_settings.bind(true))
    _new_button.pressed.connect(_new_game)
    _continue_button.pressed.connect(toggle_saves)
    _quit_button.pressed.connect(_confirm_quit_game)
    _back_to_game.pressed.connect(global_MenuManager.TogglePauseMenu)
    _start_new_game.pressed.connect(new_game)
    _cancel_new_game.pressed.connect(_close_new_game_menu)
    _confirm_quit.confirmed.connect(quit_game)
    _world_name.text_changed.connect(_enable_new_game)
    global_MenuManager.settings_menu.close.connect(toggle_settings.bind(false))
    self.visibility_changed.connect(set_visible_items)
    set_visible_items()

func try_exit() -> void:
    get_tree().quit()

func _confirm_quit_game() -> void:
    _confirm_quit.visible = true

func quit_game() -> void:
    global_GameManager.StopGame()

func toggle_settings(toggle_on : bool) -> void:
    if(toggle_on):
        global_MenuManager.SwitchMenus(global_MenuManager.settings_menu, self)
        return
    global_MenuManager.SwitchMenus(self, global_MenuManager.settings_menu)

func toggle_saves() -> void:
    _saves.visible = !_saves.visible
    if(_saves.visible):
        for world in global_WorldManager.GetWorldNames():
            var new_button : Button = _template_world.duplicate()
            new_button.name = world
            new_button.text = world
            new_button.visible = true
            new_button.theme_type_variation = &"WorldSelectButton"
            new_button.pressed.connect(try_LoadGame.bind(world))
            _save_games.add_child(new_button)
    else:
        for child in _save_games.get_children():
            child.queue_free()
        _query_saved_games()

func _enable_new_game(_unused) -> void:
    _start_new_game.disabled = false

func _new_game() -> void:
    _new_game_menu.visible = true

func new_game() -> void:
    try_StartGame(_world_name.text)
    _close_new_game_menu()

func _close_new_game_menu() -> void:
    _start_new_game.disabled = true
    _new_game_menu.visible = false

func try_StartGame(world_name : String) -> void:
    if(global_GameManager.StartNewGame(world_name) == OK):
        global_MenuManager.CloseAllMenus()

func try_LoadGame(world_save : String) -> void:
    _saves.visible = false
    if(global_GameManager.LoadGame(world_save) == OK):
        global_MenuManager.CloseAllMenus()

func set_visible_items() -> void:
    var game_running : bool = global_GameManager.IsGameRunning()
    if(!game_running):
        global_WorldManager.CheckAndCleanWorlds()
        _query_saved_games()

    _main_menu.visible = !game_running
    _pause_menu.visible = game_running

    for node in get_tree().get_nodes_in_group("StartHidden"):
        node.visible = false

func _query_saved_games() -> void:
    if(global_WorldManager.HasWorlds()):
        _continue_button.disabled = false
        _continue_button.focus_mode = Control.FOCUS_ALL
    else:
        _continue_button.disabled = true
        _continue_button.focus_mode = Control.FOCUS_NONE
        _saves.visible = false
