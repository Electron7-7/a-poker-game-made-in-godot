class_name Thing
extends Node

static var _untitled_thing_id : int = 0

static func _increment_untitled_id() -> int:
    _untitled_thing_id += 1
    return _untitled_thing_id

func _init(init_name : String = "Untitled_Thing %d" % _increment_untitled_id()) -> void:
    name = init_name
    print_debug("A new `Thing` was initialized with the name \"%s\"" % name)
