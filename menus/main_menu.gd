extends Control

static var _is_pause_menu : bool = false
static var _saves_toggle  : bool = false

@onready var _hosting_buttons : HBoxContainer = $"%HostingButtons"
@onready var _game_buttons    : HBoxContainer = $"%GameButtons"
@onready var _saves           : ScrollContainer = $"%Saves"
@onready var _save_games      : VBoxContainer = $"%SaveGames"
@onready var _settings_button : Button = $"%Settings"
@onready var _exit_button     : Button = $"%Exit"
@onready var _quit_button     : Button = $"%Quit"
@onready var _new_button      : Button = $"%New"
@onready var _continue_button : Button = $"%Continue"
@onready var _template_world  : Button = $"%_WorldTemplate"

func Toggled() -> void:
    if(global_WorldManager.HasWorlds()):
        _continue_button.disabled = false
        _continue_button.focus_mode = Control.FOCUS_ALL
    else:
        _continue_button.disabled = true
        _continue_button.focus_mode = Control.FOCUS_NONE
        _saves.visible = false

func Init() -> void:
    _saves.visible = false
    _exit_button.pressed.connect(try_exit)
    _settings_button.pressed.connect(toggle_settings.bind(true))
    _continue_button.pressed.connect(toggle_saves)
    global_MenuManager.settings_menu.close.connect(toggle_settings.bind(false))
    self.visibility_changed.connect(Toggled)

func try_exit() -> void:
    get_tree().quit()

func toggle_settings(toggle_on : bool) -> void:
    if(toggle_on):
        global_MenuManager.SwitchMenus(global_MenuManager.settings_menu, self)
        return
    global_MenuManager.SwitchMenus(self, global_MenuManager.settings_menu)

func toggle_saves() -> void:
    _saves_toggle = !_saves_toggle
    _saves.visible = _saves_toggle
    if(_saves_toggle):
        for world in global_WorldManager.GetWorldNames():
            var new_button : Button = _template_world.duplicate()
            new_button.name = world
            new_button.text = world
            new_button.visible = true
            new_button.theme_type_variation = &"WorldSelectButton"
            new_button.pressed.connect(try_load_world.bind(world))
            _save_games.add_child(new_button)
    else:
        for child in _save_games.get_children():
            child.queue_free()
    Toggled() # I just don't want to copy paste code and I'm lazy

func try_load_world(world_name : String) -> Error:
    return OK

func set_pause_menu(is_pause_menu : bool) -> void:
    _is_pause_menu = is_pause_menu
    _quit_button.visible = _is_pause_menu
    _hosting_buttons.visible = _is_pause_menu
    _game_buttons.visible = !_is_pause_menu
    _exit_button.visible = !_is_pause_menu
