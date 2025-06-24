class_name MenuManager extends Control

var _root_menu : Control = Control.new()
var _all_neighbors : Dictionary = {}

enum LoadStatus
{
    FINISHED = 0,
    FUCKED   = 1,
    IGNORED  = 2
}

func _remove_neighbors(menu : Menu):
    for child in get_children():
        if(child == _root_menu):
            continue
        _deactivate_menu(child)
        child.queue_free()
    _all_neighbors.clear()

func _preload_neighbors(menu : Menu):
    for neighbor in menu._forward_neighbors:
        if(!neighbor.can_instantiate() || find_child(neighbor.get_state().get_node_name(0)) != null):
            continue
        var new_neighbor : Menu = neighbor.instantiate() as Menu
        _all_neighbors[neighbor.get_state().get_node_name(0)] = get_child_count()
        _deactivate_menu(new_neighbor)
        add_child(new_neighbor, true)

func LoadRootMenu(new_menu : PackedScene) -> LoadStatus:
    if(new_menu.get_state().get_node_type(0) != StringName("Control")):
        printerr("MenuManager::LoadMenu(PackedScene) - Attempted to load a Scene that doesn't have a Control node as its root!")
        return LoadStatus.FUCKED

    if(new_menu.get_state().get_node_name(0) == _root_menu.name):
        print_debug("Attempted to load a Scene containing a root node with the same name as the currently loaded menu")
        return LoadStatus.IGNORED

    _remove_neighbors(_root_menu as Menu)
    _root_menu.queue_free()
    _root_menu = new_menu.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
    add_child(_root_menu, true, Node.INTERNAL_MODE_FRONT)
    _preload_neighbors(_root_menu as Menu)
    return LoadStatus.FINISHED

func SwitchMenu(new_menu : PackedScene) -> void:
    var _new_menu : Control = new_menu.instantiate()
    var _menu_name : StringName = new_menu.get_state().get_node_name(0)

    if(!_all_neighbors.has(_menu_name)):
        _all_neighbors[_menu_name] = get_child_count()
        add_child(_new_menu, true)
        _preload_neighbors(_new_menu as Menu)
    else:
        _new_menu = get_child(_all_neighbors.get(_menu_name))

    _deactivate_menu(_root_menu)
    _activate_menu(_new_menu)

func _activate_menu(menu : Control) -> void:
    menu.visible = true

func _deactivate_menu(menu : Control) -> void:
    menu.visible = false
