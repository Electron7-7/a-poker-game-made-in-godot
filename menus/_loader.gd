@tool
class_name Loader extends Button

static var _menu_script : Script = preload("res://menus/_menu.gd")

@export var menu_to_load : PackedScene = null:
    set(new_menu):
        _update_menu(new_menu, menu_to_load)
        menu_to_load = new_menu

func _ready() -> void:
    _update_menu(menu_to_load, null)

func _check_owner() -> bool:
    if(owner == null): # For when 'set(new_menu)' is called before the root Node exists
        return false
    if(owner is not Menu && owner.get_script() != _menu_script):
        printerr("(" + name + ") Loader::_check_owner() - Root node of this scene is not a Menu node (missing _menu script)! The _loader script is designed to work with the _menu script!" % name)
        return false
    return true

func _update_menu(new_neighbor : PackedScene, old_neighbor : PackedScene):
    if(!_check_owner()):
        return
    owner.update_neighbor(new_neighbor, old_neighbor)

func _pressed() -> void:
    if(!_check_owner()):
        return
    owner.goto_menu(menu_to_load)
