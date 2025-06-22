class_name WorldManager extends Node3D

static var _current_scene : PackedScene

enum LoadStatus
{
    FINISHED = 0,
    FUCKED   = 1,
    IGNORED  = 2
}

static func LoadScene(new_scene : PackedScene) -> LoadStatus:
    if(_current_scene == new_scene):
        print_debug("Attempted to load the currently loaded scene. Nothing will happen (if you would please consult the graphs), but do keep this in mind if any odd issues arise.")
        return LoadStatus.IGNORED

    _current_scene = new_scene
    return LoadStatus.FINISHED
