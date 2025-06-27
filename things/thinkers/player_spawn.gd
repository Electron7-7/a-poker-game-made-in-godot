@tool
# @icon("res://icon.png")
class_name PlayerSpawn extends Marker3D

const GroupName : String = "PlayerSpawn"
var _editor_preview : MeshInstance3D = GodotPlayer.get_editor_preview()

@export_group("Editor Player Preview")
@export var Enabled : bool = true:
    set(value):
        Enabled = value
        _editor_preview.visible = value
@export_range(0.0, 0.1, 0.001) var OutlineThickness : float = 0.025:
    set(value):
        OutlineThickness = value
        (_editor_preview.material_override as StandardMaterial3D).stencil_outline_thickness = value
@export_tool_button("Copy to all 'PlayerSpawn' Nodes", "Override") var set_global_preview_action = set_global_preview

func set_global_preview() -> void:
    for child in get_tree().get_nodes_in_group(GroupName):
        child.Enabled = Enabled
        child.OutlineThickness = OutlineThickness

func _editor_ready() -> void:
    for child in get_children(true):
        child.free()
    add_child(_editor_preview, false, INTERNAL_MODE_FRONT)
    get_child(0, true).owner = get_tree().edited_scene_root

func _ready() -> void:
    add_to_group(GroupName, true)
    if(Engine.is_editor_hint()):
        _editor_ready()
