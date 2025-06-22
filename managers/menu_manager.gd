class_name MenuManager extends Control

# Todo: replace all of this with a system where each new menu node calls a function
# to load the next menu and tells MenuManager which menu it wants to load next.
# MenuManager would store 2 variables: the currently in-use menu and the previously
# in-use menu, and would keep all menus loaded until the main menu is exited.
# Once the main menu is exited, all menus get unloaded. Only one menu is loaded
# when the MenuManager is told to start showing menus, that one menu being the
# root menu.
# Example: when told to load the "pause menu", MenuManger will load only the main
# pause menu scene and if the user navigates to a sub-menu, the main menu scene
# will tell MenuManager to load that scene. Then, if the user navigates back, that
# scene is hidden but not destroyed until the pause menu is closed.
# This ensures that menus are loaded in as quickly as possible. Although, to avoid
# lagging when quickly switching menus, I could probably implement a buffering system
# where MenuManager immediately loads the main menu first, then starts loading, in
# the background, any sub-menus that can be immediately opened up. These sub-menus
# would be hidden until needed, and would theoretically be a nice middle ground.
# Example: if the pause menu's main menu can immediately navigate to "settings"
# and "settings" can immediately navigate to "advanced settings", then when the
# pause menu is loaded, MenuManager would first load the main pause menu. Then,
# it would start loading "settings" in the background, but not "advanced settings"
# since it can't be loaded by the main pause menu. However, once "settings" is
# activated, "advanced settings" would start being loaded in the background.

var _menu : Control = Control.new()

enum LoadStatus
{
    FINISHED = 0,
    FUCKED   = 1,
    IGNORED  = 2
}

func _init() -> void:
    add_child(_menu)

func LoadMenu(Menu : PackedScene) -> LoadStatus:
    if(Menu.get_state().get_node_type(0) != StringName("Control")):
        printerr("MenuManager::LoadMenu(PackedScene) - Attempted to load a Scene that doesn't have a Control node as its root!")
        return LoadStatus.FUCKED

    if(Menu.get_state().get_node_name(0) == _menu.name):
        print_debug("Attempted to load a Scene containing a root node with the same name as the currently loaded menu")
        return LoadStatus.IGNORED

    get_child(0).queue_free()
    add_child(Menu.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE), true)
    _menu = get_child(0)
    return LoadStatus.FINISHED
