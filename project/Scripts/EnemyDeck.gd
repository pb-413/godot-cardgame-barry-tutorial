extends Deck

const CARD_SCENE_PATH = "res://Scenes/EnemyCard.tscn"

var enemy_deck = [
     "Archer", "Demon", "Tornado", "Knight",
     "Knight", "Knight", "Knight", "Knight"
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Enemy deck in enemy script.
    deck = enemy_deck

    # Load enemy card scene for draw.
    card_scene = preload(CARD_SCENE_PATH)
    hand_node = $"../EnemyHand"

    super()


func draw_card():
    var card : Card = super()
    if card:
        card.get_node("Ability").visible = false
