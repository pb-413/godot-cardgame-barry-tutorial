extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DRAW_SPEED = 1

var player_deck = ["Knight", "Knight", "Knight",]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # print($Area2D.collision_mask)
    $RichTextLabel.text = str(player_deck.size())


func draw_card():
    var card_drawn = player_deck[0]
    player_deck.erase(card_drawn)

    # Out of cards.
    if player_deck.size() == 0:
        $Area2D/CollisionShape2D.disabled = true
        $Sprite2D.visible = false
        $RichTextLabel.visible = false
    
    $RichTextLabel.text = str(player_deck.size())
    var card_scene = preload(CARD_SCENE_PATH)
    var new_card = card_scene.instantiate()
    $"../CardManager".add_child(new_card)
    new_card.name = "card"
    $"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
