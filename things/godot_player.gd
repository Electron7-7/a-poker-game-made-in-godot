@tool
class_name GodotPlayer extends Node

const _group : String = "GodotPlayer"

func _ready() -> void:
    add_to_group(_group)

