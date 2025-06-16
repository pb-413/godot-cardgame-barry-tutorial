extends Deck

const CARD_SCENE_PATH = "res://Scenes/PlayerCard.tscn"

var player_deck = [
    "Knight", "Archer", "Demon", "Knight", "Knight", "Knight", "Knight"
]
var has_drawn_for_turn : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Player deck in player script.
    deck = player_deck

    # Load player scenes as resources.
    card_scene = preload(CARD_SCENE_PATH)
    hand_node = $"../PlayerHand"

    super()

    # Player can't draw on the first turn.
    set_draw_unavailable()


func draw_card():
    set_draw_unavailable()

    var new_card = super()

    # Player cards are revealed.
    new_card.get_node("AnimationPlayer").play("card_flip")


func hide_deck():
    # Only player cards have collision.
    $Area2D/CollisionShape2D.disabled = true

    super()

    # Hide the draw indicator as well.
    $"../DrawIndicator".visible = false


func set_draw_unavailable():
    has_drawn_for_turn = true
    # Toggle draw indicator to red (0).
    $"../DrawIndicator/Area2D/AnimatedSprite2D".frame = 0


func reset_draw():
    has_drawn_for_turn = false
    # Toggle draw indicator to green (1).
    $"../DrawIndicator/Area2D/AnimatedSprite2D".frame = 1
