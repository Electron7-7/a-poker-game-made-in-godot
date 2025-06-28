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

@onready var DebugLabel : Label = $"%DebugLabel"
@onready var Collider : CollisionShape3D = $"%BodyCollider"
@onready var BoundingBox : Area3D = $"%BoundingBox"
@onready var Head : Node3D = $"%Head"
@onready var Body : Node3D = $"%Body"
@onready var Camera : Camera3D = $"%MainCamera"

const PlayerGroup : String = "GodotPlayer"

static var MaxSpeed           : int   = 999999
static var AirAcceleration    : float = 0.05
static var GroundAcceleration : float = 0.55
static var AccelerationScale  : float = 0.1
static var WalkSpeed          : float = 6.0
static var SprintSpeed        : float = 7.4
static var JumpForce          : float = 7.5
static var GravityMultiplier  : float = 2.0

var _mouse_last := Vector2.ZERO
var _direction_last := Vector2.ZERO
var _movement_lerp : float = 0.0
var wish_acceleration : float = GroundAcceleration
var gravity_scalar : float = 0.0

func set_fov(new_fov : int) -> void:
    if(Camera == null):
        return
    Camera.fov = new_fov

func _movement_speed() -> float:
    if(Input.is_action_pressed("sprint")):
        return SprintSpeed
    return WalkSpeed

func getOrientationUp() -> Vector3:
    return Body.quaternion * Vector3.UP

func getOrientationRight() -> Vector3:
    return Body.quaternion * Vector3.RIGHT

func getOrientationForward() -> Vector3:
    return Body.quaternion * Vector3.FORWARD

func process_rotation(mouse_current : Vector2) -> void:
    var pitch_wish : float = (_mouse_last.y + mouse_current.y) * (SettingsManager.MouseSensitivity * SettingsManager.MouseSensitivityScale)
    var yaw_wish   : float = (_mouse_last.x + mouse_current.x) * (SettingsManager.MouseSensitivity * SettingsManager.MouseSensitivityScale)
    Head.rotation_degrees -= Vector3(pitch_wish, 0.0, 0.0)
    Body.rotation_degrees -= Vector3(0.0, yaw_wish, 0.0)
    _mouse_last = mouse_current

func _calculate_gravity_scalar() -> float:
    return (get_gravity()[1] / Engine.physics_ticks_per_second * GravityMultiplier)

func _calculate_acceleration() -> float:
    return (wish_acceleration * AccelerationScale)

# FIXME: I would like this to be more Source-like...
func process_movement() -> void:
    var direction : Vector2 = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
    var front_back_velocity : Vector3 = Vector3(getOrientationForward()[0], 0.0, getOrientationForward()[2]) * (direction[1] * _movement_speed())
    var left_right_velocity : Vector3 = getOrientationRight() * (direction[0] * _movement_speed())
    var current_velocity : Vector3 = velocity
    var wish_velocity : Vector3 = front_back_velocity + left_right_velocity

    _movement_lerp = clamp(_movement_lerp + _calculate_acceleration(), 0.0, 1.0)
    if(direction != _direction_last || (Input.is_action_just_pressed("sprint") || Input.is_action_just_released("sprint"))):
        _movement_lerp = 0.0
    _direction_last = direction

    if(is_on_floor()):
        gravity_scalar = 0.0
        wish_acceleration = GroundAcceleration
        if(Input.is_action_just_pressed("jump", true)):
            gravity_scalar += JumpForce
            _movement_lerp = 0.0
    elif(!is_on_floor()):
        wish_acceleration = AirAcceleration
        gravity_scalar += _calculate_gravity_scalar()

    var new_velocity : Vector3 = lerp(current_velocity, wish_velocity, _movement_lerp)
    new_velocity[1] = gravity_scalar

    velocity = new_velocity

func _ready() -> void:
    add_to_group(PlayerGroup)
    Camera.fov = SettingsManager.FOV

func _physics_process(_delta : float) -> void:
    process_movement()
    move_and_slide()

func _input(event : InputEvent) -> void:
    if(MenuManager.IsPauseMenuActive()):
        return
    if(event is InputEventMouseMotion):
        process_rotation(event.screen_relative)

func _process(_delta : float) -> void:
    $"%FPS".text = String("%-3d" % Engine.get_frames_per_second())
    var debug_text : String = ""
    debug_text += String("Velocity: %0.3v" % velocity)
    DebugLabel.text = debug_text
