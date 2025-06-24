@tool
class_name Menu extends Control

var _forward_neighbors : Array[PackedScene] = []

func goto_menu(menu : PackedScene) -> void:
    if(!_forward_neighbors.has(menu)):
        printerr("(" + name + ") Menu::goto_menu(menu : PackedScene) - menu does not exist in _forward_neighbors! The menu should still load, but this is undesired behaviour.")
    if(menu == null):
        printerr("(" + name + ") Menu::goto_menu(menu : PackedScene) - menu is null!")
        return
    global_MenuManager.SwitchMenu(menu)

func update_neighbor(new_neighbor : PackedScene, old_neighbor : PackedScene = null):
    if(new_neighbor == null):
        if(old_neighbor == null || !_forward_neighbors.has(old_neighbor)):
            printerr("(" + name + ") Menu::update_neighbor - both neighbors are null!")
            return
        _forward_neighbors.erase(old_neighbor)
        return

    if(!_forward_neighbors.has(new_neighbor)):
        _forward_neighbors.append(new_neighbor)

    if(_forward_neighbors.has(old_neighbor)):
        _forward_neighbors.erase(old_neighbor)
