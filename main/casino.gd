class_name Casino extends Node2D

@onready var VisualCard : Card2D = preload("res://things/card_2d.tscn").instantiate()
@onready var shittydebugdelaytimer : Timer = $%shittydebugdelaytimer

func GetSaveData() -> void:
    pass

func _ready() -> void:
    add_child(VisualCard, true)
    VisualCard.scale = Vector2(3, 3)

func _debug_randomize_card() -> void:
    Deck.ShuffleDeck()
    VisualCard.SetCard(Deck.GetCard())

func _physics_process(_delta: float) -> void:
    if(MenuManager.IsPauseMenuActive()):
        return
    VisualCard.global_position = get_global_mouse_position()

func _process(_delta : float) -> void:
    if(MenuManager.IsPauseMenuActive()):
        return
    if(Input.is_action_just_pressed("click")):
        shittydebugdelaytimer.start(0.5)
        _debug_randomize_card()

    if(Input.is_action_pressed("click") && shittydebugdelaytimer.is_stopped()):
        shittydebugdelaytimer.start(0.07)
        _debug_randomize_card()

    if(Input.is_action_pressed("secondary_click")):
        _debug_randomize_card()

    if(Input.is_action_just_released("scroll_up", true)):
        VisualCard.debug_CycleRank(1)

    if(Input.is_action_just_released("scroll_down", true)):
        VisualCard.debug_CycleRank(-1)
