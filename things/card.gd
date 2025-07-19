class_name Card extends Node2D

## Handles all card-related logic.

## Used to identify and compare card ranks.[br]
enum Rank
{
    ACE      = 1,
    TWO      = 2,
    THREE    = 3,
    FOUR     = 4,
    FIVE     = 5,
    SIX      = 6,
    SEVEN    = 7,
    EIGHT    = 8,
    NINE     = 9,
    TEN      = 10,
    KNAVE    = 11,
    QUEEN    = 12,
    KING     = 13
}

## Used to identify and compare card suits.
enum Suit
{
    SPADES   = 0,
    CLUBS    = 1,
    HEARTS   = 2,
    DIAMONDS = 3
}

## Stores the [enum Rank] of the [Card]. Made private in order to be pseudo-constant.
var _rank : Rank = Rank.ACE

## Stores the [enum Suit] of the [Card]. Made private in order to be pseudo-constant.
var _suit : Suit = Suit.SPADES

func _init(rank : Rank = Rank.ACE, suit : Suit = Suit.SPADES) -> void:
    _rank = rank
    _suit = suit
    _setup_children()

func _setup_children() -> void:
    pass

## Getter for [member _rank].[br][br]
func GetRank() -> Rank:
        return _rank

## Getter for [member _suit].
func GetSuit() -> Suit:
    return _suit

## Used to compare the [member _suit] value of one [Card] to another.
func equal_suits(compare_to : Card) -> bool:
    return (_suit == compare_to._suit)

## Used to compare both the [member _suit] [i]and[/i] [member _rank] values of one [Card] to another.
func compare(compare_to : Card) -> bool:
    return (_rank == compare_to._rank) && (_suit == compare_to._suit)

## Used to check if the [member _rank] of one [Card] is equal to another.
func equal(compare_to : Card) -> bool:
    return (_rank == compare_to._rank)

## Used to check if the [member _rank] of one [Card] is greater than another.
func greater(compare_to : Card, aces_high : bool = true) -> bool:
    if(equal(compare_to)):
        return false
    if(_rank == Rank.ACE):
        return aces_high
    if(compare_to._rank == Rank.ACE):
        return !aces_high
    return (_rank > compare_to._rank)

## Used to check if the [member _rank] of one [Card] is less than another.
func less(compare_to : Card, aces_high : bool = true) -> bool:
    if(equal(compare_to)):
        return false
    if(_rank == Rank.ACE):
        return !aces_high
    if(compare_to._rank == Rank.ACE):
        return aces_high
    return (_rank < compare_to._rank)
