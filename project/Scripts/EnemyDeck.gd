extends Node2D

const CARD_SCENE_PATH = "res://Scenes/EnemyCard.tscn"
const CARD_DRAW_SPEED = .3
const STARTING_HAND_SIZE = 4

var enemy_deck = [
    "Knight", "Archer", "Demon", "Knight", "Knight", "Knight", "Knight"
]
var card_database_reference : Dictionary
var has_drawn_for_turn : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    enemy_deck.shuffle()
    $RichTextLabel.text = str(enemy_deck.size())
    card_database_reference = load("res://Resources/CardDatabase.tres").data
    for i in range(STARTING_HAND_SIZE):
        draw_card()
        has_drawn_for_turn = false
    has_drawn_for_turn = true


func draw_card():
    if has_drawn_for_turn:
        return
    has_drawn_for_turn = true
    var card_drawn_name: String = enemy_deck[0]
    enemy_deck.erase(card_drawn_name)

    # Out of cards.
    if enemy_deck.size() == 0:
        $Area2D/CollisionShape2D.disabled = true
        $Sprite2D.visible = false
        $RichTextLabel.visible = false

    $RichTextLabel.text = str(enemy_deck.size())
    var card_scene = preload(CARD_SCENE_PATH)
    var new_card = card_scene.instantiate()
    var card_image_path = str("res://Assets/" + card_drawn_name + "Card.png")
    new_card.get_node("CardImage").texture = load(card_image_path)
    new_card.get_node("Attack").text = str(card_database_reference[card_drawn_name]["Attack"])
    new_card.get_node("Health").text = str(card_database_reference[card_drawn_name]["Health"])
    new_card.card_type = card_database_reference[card_drawn_name]["Type"]
    $"../CardManager".add_child(new_card)
    new_card.name = "card"
    $"../EnemyHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
    # Enemy card is hidden in hand!
    # new_card.get_node("AnimationPlayer").play("card_flip")
