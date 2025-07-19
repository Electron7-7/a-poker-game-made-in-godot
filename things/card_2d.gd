class_name Card2D extends Node2D

@onready var corner_sprites : Array[Sprite2D] = \
[
    $%BottomLeft,
    $%BottomRight,
    $%TopLeft,
    $%TopRight
]

@onready var suit_sprite : Node2D = $%SuitSprite
@onready var suit_markers_parent : Node2D = $%SpriteMarkers
@onready var suit_markers : Array[Node] = $%SpriteMarkers.get_children()
@onready var suit_markers_max : int = $%SpriteMarkers.get_child_count()
@onready var king_queen_knave_sprite : Node2D = $%KingQueenKnave

var card : Card = Card.new()
var region_conversion_magic_number : int = 100
var region_king_queen_knave_conversion_magic_number : int = 3
var black_color := Color.BLACK
var red_color := Color.RED
var king_queen_knave_color_on_black := Color(0.3, 0.627, 1.0, 1.0)
var king_queen_knave_color_on_red := Color(0.9, 0.9, 0.0, 1.0)
var suit_size_small := Vector2(0.23, 0.23)

func _ready() -> void:
    for child in suit_markers:
        child.add_child(suit_sprite.duplicate())
    suit_markers_parent.visible = false

func SetSuitSprites() -> void:
    suit_markers_parent.visible = false
    king_queen_knave_sprite.visible = false
    suit_sprite.visible = true
    suit_sprite.scale = Vector2.ONE

    if(card.GetRank() == Card.Rank.ACE):
        return

    if(card.GetRank() == Card.Rank.KNAVE || card.GetRank() == Card.Rank.QUEEN || card.GetRank() == Card.Rank.KING):
        king_queen_knave_sprite.visible = true
        king_queen_knave_sprite.region_rect.position.x = ((card.GetRank() - Card.Rank.KNAVE) + card.GetSuit() * region_king_queen_knave_conversion_magic_number) * region_conversion_magic_number
        return

    suit_markers_parent.visible = true
    suit_sprite.visible = false

    for iteration in range(card.GetRank()):
        suit_markers.get(iteration).visible = true

    for iteration in range(card.GetRank(), suit_markers_max):
        suit_markers.get(iteration).visible = false

func SetCard(new_card : Card) -> void:
    card = new_card
    var sprite_color : Color = black_color
    var secondary_sprite_color : Color = king_queen_knave_color_on_black
    if(card.GetSuit() == Card.Suit.HEARTS || card.GetSuit() == Card.Suit.DIAMONDS):
        sprite_color = red_color
        secondary_sprite_color = king_queen_knave_color_on_red
    for corner_sprite : Sprite2D in corner_sprites:
        corner_sprite.region_rect.position.x = (card.GetRank() - 1) * region_conversion_magic_number
        corner_sprite.modulate = sprite_color
    suit_sprite.region_rect.position.x = card.GetSuit() * region_conversion_magic_number
    suit_sprite.modulate = sprite_color
    king_queen_knave_sprite.modulate = secondary_sprite_color
    for child in suit_markers:
        var sub_child : Sprite2D = child.get_child(0)
        sub_child.rotation = child.rotation
        sub_child.scale = suit_size_small
        sub_child.region_rect.position.x = card.GetSuit() * region_conversion_magic_number
        sub_child.modulate = sprite_color
        child.visible = false
    SetSuitSprites()

# Terrible, horrible, no good, very bad debugging code
func debug_CycleRank(cycle_direction : int = 1) -> void:
    var new_rank : Card.Rank = (card.GetRank() + cycle_direction as Card.Rank)
    var new_suit : Card.Suit = card.GetSuit()
    if(new_rank > Card.Rank.KING || new_rank < Card.Rank.ACE):
        new_suit = (new_suit + cycle_direction as Card.Suit)
        if(new_suit > Card.Suit.DIAMONDS):
            new_suit = Card.Suit.SPADES
        elif(new_suit < Card.Suit.SPADES):
            new_suit = Card.Suit.DIAMONDS
    if(new_rank > Card.Rank.KING):
        new_rank = Card.Rank.ACE
    if(new_rank < Card.Rank.ACE):
        new_rank = Card.Rank.KING
    SetCard(Card.new(new_rank, new_suit))
