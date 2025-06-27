class_name GodotPlayer extends CharacterBody3D

static func get_editor_preview() -> MeshInstance3D:
    var editor_preview := MeshInstance3D.new()
    editor_preview.mesh = CapsuleMesh.new()
    editor_preview.material_override = StandardMaterial3D.new()
    (editor_preview.material_override as StandardMaterial3D).stencil_mode = BaseMaterial3D.STENCIL_MODE_OUTLINE
    (editor_preview.material_override as StandardMaterial3D).stencil_color = Color.BLACK
    (editor_preview.material_override as StandardMaterial3D).stencil_outline_thickness = 0.025
    (editor_preview.material_override as StandardMaterial3D).albedo_color = Color.MAGENTA
    return editor_preview

@onready var Collider : CollisionShape3D = $"%BodyCollider"
@onready var BoundingBox : Area3D = $"%BoundingBox"
@onready var Head : Node3D = $"%Head"

var _mouse_last : Vector2 = Vector2(0.0, 0.0)

func _physics_process(_delta: float) -> void:
    pass

func _process(_delta: float) -> void:
    pass

func rotate_head(mouse_current : Vector2) -> void:
    var pitch_wish : float = (_mouse_last.y + mouse_current.y) * SettingsManager.MouseSensitivity
    var yaw_wish   : float = (_mouse_last.x + mouse_current.x) * SettingsManager.MouseSensitivity
    Head.rotation_degrees -= Vector3(pitch_wish, yaw_wish, 0.0)
    _mouse_last = mouse_current

func _input(event : InputEvent) -> void:
    if(MenuManager.IsPauseMenuActive()):
        return
    if(event is InputEventMouseMotion):
        rotate_head(event.screen_relative)
