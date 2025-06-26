@tool
class_name World extends Node3D

static var things : Array[Node] = []

func _free_all_children() -> void:
    for child in get_children():
        child.free()

func _ready() -> void:
    if(Engine.is_editor_hint()):
        _free_all_children()
