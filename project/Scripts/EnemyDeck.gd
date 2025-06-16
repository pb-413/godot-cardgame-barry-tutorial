extends Deck

const CARD_SCENE_PATH = "res://Scenes/EnemyCard.tscn"

var enemy_deck = [
    "Knight", "Archer", "Knight", "Knight", "Knight", "Knight" #, "Demon"
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Enemy deck in enemy script.
    deck = enemy_deck

    # Load enemy card scene for draw.
    card_scene = preload(CARD_SCENE_PATH)
    hand_node = $"../EnemyHand"

    super()
