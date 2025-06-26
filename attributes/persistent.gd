@tool
class_name Persistent extends Node

# Unused class with code that might come in handy later

const _node_name  : String = "is_persistent"
const _group_name : String = "Persist"

func _init() -> void:
    name = _node_name

func _ready() -> void:
    assert(get_parent() != null, "The 'Persistent' Node must be a child of another Node")
    get_parent().add_to_group(_group_name)
