class_name Deck extends Object

## Handles all deck-related logic.

static var _cards : Array[Card] = []
static var _unshuffled_deck : Array[Card] = []

static func _static_init() -> void:
    for suit in range(Card.Suit.DIAMONDS + 1):
        for rank in range(Card.Rank.ACE, Card.Rank.KING + 1):
            _unshuffled_deck.append(Card.new(rank, suit))
    _cards = _unshuffled_deck

static func _get_shuffled_deck() -> Array[Card]:
    randomize()
    var new_deck : Array[Card] = []
    var try_random : int = randi_range(0, 51)
    for i in range(52):
        while(new_deck.has(_unshuffled_deck.get(try_random))):
            try_random = randi_range(0, 51)
        new_deck.append(_unshuffled_deck.get(try_random))
    return new_deck

static func ShuffleDeck() -> void:
    _cards = _get_shuffled_deck()

static func UnshuffleDeck() -> void:
    _cards = _unshuffled_deck

static func GetCard(index : int = 0) -> Card:
    return _cards.get(index)
